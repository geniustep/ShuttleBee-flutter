import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shuttlebee/core/config/app_config.dart';
import 'package:shuttlebee/core/constants/api_constants.dart';
import 'package:shuttlebee/core/errors/exceptions.dart';
import 'package:shuttlebee/core/errors/failures.dart';
import 'package:shuttlebee/core/network/dio_interceptors.dart';
import 'package:shuttlebee/core/utils/logger.dart';

/// BridgeCore API Client
class ApiClient {
  ApiClient({
    FlutterSecureStorage? storage,
    Dio? dio,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _dio = dio ?? Dio() {
    _setupDio();
  }

  final FlutterSecureStorage _storage;
  final Dio _dio;

  /// Setup Dio configurations و Interceptors
  void _setupDio() {
    final normalizedBase = AppConfig.apiBaseUrl.endsWith('/')
        ? AppConfig.apiBaseUrl.substring(0, AppConfig.apiBaseUrl.length - 1)
        : AppConfig.apiBaseUrl;

    _dio.options = BaseOptions(
      baseUrl: '$normalizedBase/',
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      headers: {
        'Content-Type': ApiConstants.contentTypeJson,
        'Accept': ApiConstants.acceptJson,
      },
      validateStatus: (status) => status != null && status < 500,
    );

    // Add interceptors
    _dio.interceptors.addAll([
      AuthInterceptor(storage: _storage, dio: _dio),
      LoggingInterceptor(),
      RetryInterceptor(),
    ]);
  }

  /// GET Request
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      AppLogger.error('GET Request failed: $path', e);
      throw UnexpectedFailure.fromException(e);
    }
  }

  /// POST Request
  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      AppLogger.error('POST Request failed: $path', e);
      throw UnexpectedFailure.fromException(e);
    }
  }

  /// PUT Request
  Future<Map<String, dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      AppLogger.error('PUT Request failed: $path', e);
      throw UnexpectedFailure.fromException(e);
    }
  }

  /// DELETE Request
  Future<Map<String, dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      AppLogger.error('DELETE Request failed: $path', e);
      throw UnexpectedFailure.fromException(e);
    }
  }

  /// PATCH Request
  Future<Map<String, dynamic>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      AppLogger.error('PATCH Request failed: $path', e);
      throw UnexpectedFailure.fromException(e);
    }
  }

  /// Upload File
  Future<Map<String, dynamic>> uploadFile(
    String path,
    String filePath, {
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...?data,
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      AppLogger.error('Upload file failed: $path', e);
      throw const FileException('فشل رفع الملف');
    }
  }

  /// Download File
  Future<void> downloadFile(
    String path,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      await _dio.download(
        path,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      AppLogger.error('Download file failed: $path', e);
      throw const FileException('فشل تحميل الملف');
    }
  }

  /// Handle Response
  Map<String, dynamic> _handleResponse(Response<Map<String, dynamic>> response) {
    final statusCode = response.statusCode ?? 0;

    if (statusCode >= 200 && statusCode < 300) {
      return response.data ?? {};
    } else if (statusCode == 401) {
      throw const AuthenticationException(
        'غير مصرح لك بالوصول. يرجى تسجيل الدخول مرة أخرى.',
      );
    } else if (statusCode == 403) {
      throw const PermissionException('ليس لديك صلاحية للقيام بهذا الإجراء');
    } else if (statusCode == 404) {
      throw const ServerException('المورد المطلوب غير موجود');
    } else if (statusCode == 422) {
      final errors = response.data?['errors'] as Map<String, dynamic>?;
      if (errors != null) {
        throw ValidationException.fromErrors(
          errors.map(
            (key, value) => MapEntry(key, List<String>.from(value as List)),
          ),
        );
      }
      throw const ValidationException('خطأ في التحقق من البيانات');
    } else {
      throw ServerException.fromStatusCode(
        statusCode,
        message: response.data?['message'] as String?,
      );
    }
  }

  /// Handle Dio Exception
  Object _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException(
          'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.',
        );

      case DioExceptionType.connectionError:
        return const NetworkException(
          'لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال.',
        );

      case DioExceptionType.badResponse:
        if (e.response != null) {
          return ServerException.fromStatusCode(
            e.response!.statusCode ?? 500,
            message: e.response!.data?['message'] as String?,
          );
        }
        return const ServerException('حدث خطأ في الخادم');

      case DioExceptionType.cancel:
        return const AppException('تم إلغاء الطلب');

      case DioExceptionType.badCertificate:
        return const ServerException('خطأ في شهادة الأمان');

      case DioExceptionType.unknown:
      default:
        if (e.error is Exception) {
          return e.error as Exception;
        }
        return UnexpectedFailure.fromException(e);
    }
  }

  /// Close Dio client
  void close() {
    _dio.close();
  }
}
