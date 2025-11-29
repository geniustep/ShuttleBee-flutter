import 'package:bridgecore_flutter/bridgecore_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shuttlebee/core/config/app_config.dart';
import 'package:shuttlebee/core/constants/api_constants.dart';
import 'package:shuttlebee/core/constants/app_constants.dart';
import 'package:shuttlebee/core/errors/exceptions.dart';
import 'package:shuttlebee/core/utils/logger.dart';

/// Auth Interceptor - إدارة التوكن و Auto Refresh باستخدام BridgeCore SDK
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required FlutterSecureStorage storage,
    required Dio dio,
  })  : _storage = storage,
        _dio = dio;

  final FlutterSecureStorage _storage;
  final Dio _dio;
  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // إضافة Access Token للـ requests (ما عدا login و refresh)
    if (!_isAuthEndpoint(options.path)) {
      // BridgeCore SDK يدير التوكنات تلقائياً، لكن Interceptor يحتاج الوصول للتوكن
      // نحصل عليه من SecureStorage (BridgeCoreService يحفظه هناك بعد login)
      final accessToken = await _storage.read(
        key: AppConstants.accessTokenKey,
      );

      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers[ApiConstants.authorizationHeader] =
            'Bearer $accessToken';
      }
    }

    // إضافة Accept-Language header
    final language = await _storage.read(key: AppConstants.languageKey);
    options.headers[ApiConstants.acceptLanguageHeader] =
        language ?? AppConstants.languageArabic;

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Auto refresh token on 401
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      try {
        _isRefreshing = true;

        // محاولة تحديث التوكن
        await _refreshToken();

        // إعادة المحاولة مع التوكن الجديد
        final options = err.requestOptions;
        final accessToken = await _storage.read(
          key: AppConstants.accessTokenKey,
        );

        if (accessToken != null) {
          options.headers[ApiConstants.authorizationHeader] =
              'Bearer $accessToken';

          final response = await _dio.fetch(options);
          handler.resolve(response);
        } else {
          handler.reject(err);
        }
      } catch (e) {
        AppLogger.error('Token refresh failed', e);
        // حذف التوكنات وإرجاع خطأ authentication
        await _clearTokens();
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const AuthenticationException(
              'انتهت جلستك. يرجى تسجيل الدخول مرة أخرى.',
            ),
          ),
        );
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.next(err);
    }
  }

  /// تحديث التوكن باستخدام BridgeCore Tenant-Based API
  Future<void> _refreshToken() async {
    AppLogger.debug('🔄 [AuthInterceptor] Attempting to refresh token');

    // الحصول على refresh token من SecureStorage
    final refreshToken = await _storage.read(
      key: AppConstants.refreshTokenKey,
    );

    if (refreshToken == null || refreshToken.isEmpty) {
      throw const AuthenticationException('لا يوجد refresh token');
    }

    try {
      // استخدام Tenant-Based API endpoint لتحديث التوكن
      // POST /api/v1/auth/tenant/refresh
      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/api/v1/auth/tenant/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // حفظ التوكنات الجديدة في SecureStorage
        if (data.containsKey('access_token')) {
          await _storage.write(
            key: AppConstants.accessTokenKey,
            value: data['access_token'] as String,
          );
          AppLogger.debug(
              '✅ [AuthInterceptor] Access token refreshed and saved');
        }

        // تحديث refresh token إذا كان موجوداً في الاستجابة
        if (data.containsKey('refresh_token')) {
          await _storage.write(
            key: AppConstants.refreshTokenKey,
            value: data['refresh_token'] as String,
          );
          AppLogger.debug('✅ [AuthInterceptor] Refresh token updated');
        }

        // BridgeCore SDK يدير التوكنات تلقائياً، لكن نحتاج للتأكد من التزامن
        // SDK سيستخدم التوكنات الجديدة في الطلبات التالية تلقائياً
      } else {
        throw const AuthenticationException('فشل تحديث التوكن');
      }
    } on DioException catch (e) {
      AppLogger.error('❌ [AuthInterceptor] Token refresh failed: ${e.message}');

      if (e.response?.statusCode == 401) {
        throw const AuthenticationException(
          'انتهت صلاحية refresh token. يرجى تسجيل الدخول مرة أخرى.',
        );
      }

      throw AuthenticationException(
          'فشل تحديث التوكن: ${e.message ?? e.toString()}');
    } catch (e) {
      AppLogger.error(
          '❌ [AuthInterceptor] Unexpected error during token refresh: $e');
      throw AuthenticationException('فشل تحديث التوكن: ${e.toString()}');
    }
  }

  /// حذف التوكنات من BridgeCore SDK و SecureStorage
  Future<void> _clearTokens() async {
    try {
      // حذف من BridgeCore SDK
      await BridgeCore.instance.auth.logout();
    } catch (_) {
      // تجاهل الخطأ إذا لم يكن هناك session
    }

    // حذف من SecureStorage
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);

    AppLogger.debug(
        '🗑️ [AuthInterceptor] Tokens cleared from both SDK and storage');
  }

  /// هل الـ endpoint خاص بالمصادقة
  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/tenant/login') ||
        path.contains('/auth/tenant/refresh') ||
        path.contains('/auth/tenant/logout') ||
        path.contains('/auth/login') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/logout');
  }
}

/// Logging Interceptor - لتسجيل الـ requests و responses
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.logRequest(
      options.method,
      options.uri.toString(),
      data: options.data,
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.logResponse(
      response.requestOptions.method,
      response.requestOptions.uri.toString(),
      response.statusCode ?? 0,
      data: response.data,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.logNetworkError(
      err.requestOptions.method,
      err.requestOptions.uri.toString(),
      err.message ?? err.error,
    );
    handler.next(err);
  }
}

/// Retry Interceptor - إعادة المحاولة عند الفشل
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    this.maxRetries = ApiConstants.maxRetries,
    this.retryDelay = ApiConstants.retryDelay,
  });

  final int maxRetries;
  final Duration retryDelay;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // إعادة المحاولة فقط للأخطاء التي يمكن إعادة المحاولة فيها
    if (_shouldRetry(err)) {
      final retries = err.requestOptions.extra['retries'] as int? ?? 0;

      if (retries < maxRetries) {
        // Exponential backoff
        final delay = retryDelay * (retries + 1);
        await Future<void>.delayed(delay);

        // تحديث عدد المحاولات
        err.requestOptions.extra['retries'] = retries + 1;

        AppLogger.info(
          'Retrying request (${retries + 1}/$maxRetries): '
          '${err.requestOptions.uri}',
        );

        try {
          final response = await Dio().fetch(err.requestOptions);
          handler.resolve(response);
        } catch (e) {
          handler.next(err);
        }
      } else {
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }

  /// هل يمكن إعادة المحاولة
  bool _shouldRetry(DioException err) {
    // إعادة المحاولة فقط للأخطاء المتعلقة بالشبكة أو timeout
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}
