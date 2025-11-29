import 'package:bridgecore_flutter/bridgecore_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shuttlebee/core/config/app_config.dart';
import 'package:shuttlebee/core/constants/api_constants.dart';
import 'package:shuttlebee/core/constants/app_constants.dart';
import 'package:shuttlebee/core/network/api_client.dart';
import 'package:shuttlebee/core/utils/logger.dart';

/// BridgeCore service wrapper for Odoo integration using bridgecore_flutter SDK.
/// يعتمد بشكل كامل على BridgeCore SDK لإدارة التوكنات والعمليات.
class BridgeCoreService {
  BridgeCoreService({
    String? systemId,
    ApiClient? apiClient,
    FlutterSecureStorage? storage,
  })  : _systemId = systemId ?? AppConfig.systemId,
        _apiClient = apiClient,
        _storage = storage ?? const FlutterSecureStorage();

  String _systemId;
  final ApiClient? _apiClient;
  final FlutterSecureStorage _storage;

  /// Get the current system ID
  String get systemId => _systemId;

  /// Set the system ID
  void setSystemId(String systemId) {
    _systemId = systemId;
  }

  // ========== Authentication ==========

  Future<Map<String, dynamic>> login({
    required String url,
    required String database,
    required String username,
    required String password,
  }) async {
    try {
      // مسح أي token موجود مسبقاً قبل login
      // لأن SDK قد يضيف token تلقائياً لجميع الطلبات
      try {
        await BridgeCore.instance.auth.logout();
      } catch (_) {
        await _storage.delete(key: AppConstants.accessTokenKey);
        await _storage.delete(key: AppConstants.refreshTokenKey);
        // تجاهل خطأ logout إذا لم يكن هناك session
      }

      // Use SDK for tenant-based login
      // Note: في Tenant-Based API، لا حاجة لإرسال url و database
      // لأنها مخزنة في قاعدة البيانات للـ tenant
      // SDK يتعامل مع tenant login تلقائياً
      AppLogger.debug('🔐 [login] Attempting login with email: $username');

      final session = await BridgeCore.instance.auth.login(
        email: username, // Tenant-based API يستخدم email
        password: password,
      );

      AppLogger.info(
          '✅ [login] Login successful, saving tokens to SecureStorage');

      // SDK يحفظ التوكنات تلقائياً، لكن نحتاج لحفظها أيضاً في SecureStorage
      // للتوافق مع الكود القديم الذي يتحقق من SecureStorage (مثل AuthInterceptor)
      await _storage.write(
        key: AppConstants.accessTokenKey,
        value: session.accessToken,
      );
      await _storage.write(
        key: AppConstants.refreshTokenKey,
        value: session.refreshToken,
      );

      AppLogger.debug(
          '✅ [login] Tokens saved to SecureStorage for compatibility');

      // Convert TenantSession to Map for compatibility
      final response = {
        'access_token': session.accessToken,
        'refresh_token': session.refreshToken,
        'token_type': 'Bearer',
        'expires_in': session.expiresIn,
        // system_id قد لا يكون موجوداً في tenant-based API
        if (_systemId.isNotEmpty) 'system_id': _systemId,
      };

      return response;
    } on BridgeCoreException catch (e) {
      // تحسين رسالة الخطأ
      String errorMessage = e.message;
      if (e is NetworkException) {
        errorMessage =
            'لا يمكن الاتصال بالخادم. تأكد من أن الخادم يعمل على ${AppConfig.apiBaseUrl}';
      } else if (e.message.contains('401') ||
          e.message.contains('unauthorized') ||
          e.message.contains('invalid') ||
          e.message.contains('credentials')) {
        errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      }
      throw Exception(errorMessage);
    } catch (e) {
      // معالجة أخطاء الاتصال
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception(
          'لا يمكن الاتصال بالخادم. تأكد من:\n'
          '1. الخادم يعمل على ${AppConfig.apiBaseUrl}\n'
          '2. الاتصال بالإنترنت نشط',
        );
      }
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      AppLogger.debug('🚪 [logout] Logging out from BridgeCore SDK');

      // Use SDK for logout
      await BridgeCore.instance.auth.logout();

      // حذف التوكنات من SecureStorage أيضاً للتوافق
      await _storage.delete(key: AppConstants.accessTokenKey);
      await _storage.delete(key: AppConstants.refreshTokenKey);

      AppLogger.info('✅ [logout] Logout successful, tokens cleared');
      return {'success': true};
    } on BridgeCoreException catch (e) {
      AppLogger.error('❌ [logout] BridgeCoreException: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      AppLogger.error('❌ [logout] Unexpected error: $e');
      throw Exception(e.toString());
    }
  }

  /// Connect system after authentication (requires bearer token)
  ///
  /// IMPORTANT: في Tenant-Based API:
  /// - لا يوجد اتصال مباشر بـ Odoo من التطبيق
  /// - كل العمليات تمر عبر BridgeCore API (bridgecore.geniura.com)
  /// - Odoo URL و Database يتم جلبها تلقائياً من قاعدة البيانات للـ tenant
  /// - لا حاجة لإرسال url أو database في الطلبات
  ///

  /// ✅ الحصول على معلومات المستخدم الحالي باستخدام /me endpoint (BridgeCore v0.2.0)
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      // استخدام BridgeCore مباشرة مع odoo_fields_check
      final meResponse = await BridgeCore.instance.auth.me(
        odooFieldsCheck: OdooFieldsCheck(
          model: 'res.users',
          listFields: ['shuttle_role'],
        ),
        forceRefresh: true, // للحصول على بيانات محدثة
      );

      // تحويل الاستجابة إلى Map
      final responseJson = meResponse.toJson();

      // طباعة log للبيانات المستلمة
      AppLogger.info(
          '📥 [getCurrentUser] Received user data from /me endpoint');
      AppLogger.debug(
          '📥 [getCurrentUser] User ID: ${responseJson['user']?['id']}');
      AppLogger.debug(
          '📥 [getCurrentUser] User Name: ${responseJson['user']?['name']}');
      AppLogger.debug(
          '📥 [getCurrentUser] User Email: ${responseJson['user']?['email']}');
      AppLogger.debug(
          '📥 [getCurrentUser] Partner ID: ${meResponse.partnerId}');
      AppLogger.debug(
          '📥 [getCurrentUser] Employee ID: ${meResponse.employeeId}');
      AppLogger.debug('📥 [getCurrentUser] Is Admin: ${meResponse.isAdmin}');
      AppLogger.debug(
          '📥 [getCurrentUser] Is Internal User: ${meResponse.isInternalUser}');
      AppLogger.debug('📥 [getCurrentUser] Groups: ${meResponse.groups}');
      AppLogger.debug(
          '📥 [getCurrentUser] Company IDs: ${meResponse.companyIds}');
      AppLogger.debug(
          '📥 [getCurrentUser] Current Company ID: ${meResponse.currentCompanyId}');
      AppLogger.debug(
          '📥 [getCurrentUser] Odoo Fields Data: ${meResponse.odooFieldsData}');
      AppLogger.debug(
          '📥 [getCurrentUser] Shuttle Role: ${meResponse.odooFieldsData?['shuttle_role']}');

      final response = {
        'user': responseJson['user'] ?? {},
        'tenant': responseJson['tenant'] ?? {},
        'partner_id': meResponse.partnerId,
        'employee_id': meResponse.employeeId,
        'groups': meResponse.groups,
        'is_admin': meResponse.isAdmin,
        'is_internal_user': meResponse.isInternalUser,
        'company_ids': meResponse.companyIds,
        'current_company_id': meResponse.currentCompanyId,
        'odoo_fields_data': meResponse.odooFieldsData ?? {},
        // للوصول المباشر لـ shuttle_role
        'shuttle_role': meResponse.odooFieldsData?['shuttle_role'],
      };

      AppLogger.info('✅ [getCurrentUser] Successfully processed user data');
      return response;
    } catch (e) {
      throw Exception('Failed to get current user: ${e.toString()}');
    }
  }

  // ========== CRUD Operations ==========

  Future<List<Map<String, dynamic>>> read({
    required String model,
    List<int>? ids,
    List<String>? fields,
    int? limit,
    int? offset,
  }) async {
    try {
      if (ids == null || ids.isEmpty) {
        return [];
      }

      // SDK read doesn't support limit/offset, so we'll use searchRead instead
      if (limit != null || offset != null) {
        return await search(
          model: model,
          domain: [
            ['id', 'in', ids],
          ],
          fields: fields,
          limit: limit,
          offset: offset,
        );
      }

      final results = await BridgeCore.instance.odoo.read(
        model: model,
        ids: ids,
        fields: fields ?? [],
      );

      return results
          .map((record) => Map<String, dynamic>.from(record))
          .toList();
    } on BridgeCoreException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<List<Map<String, dynamic>>> search({
    required String model,
    List<dynamic>? domain,
    List<String>? fields,
    int? limit,
    int? offset,
    String? order,
  }) async {
    try {
      // Log request details for debugging
      AppLogger.debug('🔍 [search] Model: $model');
      AppLogger.debug('🔍 [search] Domain: ${domain ?? []}');
      AppLogger.debug('🔍 [search] Fields: ${fields ?? []}');
      AppLogger.debug(
          '🔍 [search] Limit: ${limit ?? 0}, Offset: ${offset ?? 0}');

      // محاولة البحث مع الحقول المحددة
      // Note: BridgeCore API requires limit >= 1, so we use a high default if not specified
      final effectiveLimit = (limit == null || limit <= 0) ? 1000 : limit;
      final effectiveOffset = offset ?? 0;

      try {
        // If fields is empty or null, don't pass it to let SDK use default behavior
        final effectiveFields =
            (fields == null || fields.isEmpty) ? null : fields;

        AppLogger.debug('🔍 [search] Effective fields: $effectiveFields');

        List<Map<String, dynamic>> result;

        result = await BridgeCore.instance.odoo.searchRead(
          model: model,
        );

        AppLogger.debug('✅ [search] Found ${result.length} records');

        // Log first record for debugging field names
        if (result.isNotEmpty) {
          AppLogger.debug(
              '📋 [search] First record keys: ${result.first.keys.toList()}');
        }

        return result;
      } on DioException catch (dioError) {
        // Capture DioException to get the actual response body
        AppLogger.error('❌ [search] DioException caught:');
        AppLogger.error(
            '❌ [search] Status code: ${dioError.response?.statusCode}');
        AppLogger.error('❌ [search] Response data: ${dioError.response?.data}');
        AppLogger.error(
            '❌ [search] Request path: ${dioError.requestOptions.path}');
        AppLogger.error(
            '❌ [search] Request data: ${dioError.requestOptions.data}');
        rethrow;
      } on BridgeCoreException catch (e) {
        // إذا كان الخطأ 422 (validation error)، جرب بدون fields محددة
        if (e.message.contains('422') ||
            e.message.contains('bad syntax') ||
            e.message.contains('cannot be fulfilled')) {
          AppLogger.warning(
              '⚠️ [search] 422 error with specified fields, trying without fields...');

          // محاولة البحث بدون fields (سيجلب جميع الحقول)
          try {
            final result = await BridgeCore.instance.odoo.searchRead(
              model: model,
              domain: domain ?? [],
              fields: [], // Empty fields = get all fields
              limit: effectiveLimit,
              offset: effectiveOffset,
              order: order,
              useSmartFallback: true,
            );

            AppLogger.debug(
                '✅ [search] Found ${result.length} records (without specified fields)');
            return result;
          } catch (fallbackError) {
            // إذا فشل أيضاً، أعد الخطأ الأصلي
            AppLogger.error('❌ [search] Fallback also failed: $fallbackError');
            rethrow;
          }
        } else {
          // إذا لم يكن خطأ 422، أعد الخطأ الأصلي
          rethrow;
        }
      }
    } on BridgeCoreException catch (e) {
      // تحسين رسائل الخطأ
      String errorMessage = e.message;

      // Log error details with full exception info
      AppLogger.error('❌ [search] BridgeCoreException: $errorMessage');
      AppLogger.error('❌ [search] Model: $model, Domain: ${domain ?? []}');
      AppLogger.error('❌ [search] Fields: ${fields ?? []}');
      AppLogger.error('❌ [search] Full exception: ${e.toString()}');
      AppLogger.error('❌ [search] Exception type: ${e.runtimeType}');

      // معالجة أخطاء Odoo connection
      if (errorMessage.contains('Name or service not known') ||
          errorMessage.contains('Odoo authentication failed')) {
        errorMessage =
            'لا يمكن الاتصال بخادم Odoo. يرجى التحقق من إعدادات الخادم.';
      } else if (errorMessage.contains('401') ||
          errorMessage.contains('authentication failed')) {
        errorMessage = 'فشل المصادقة مع Odoo. يرجى التحقق من بيانات الاعتماد.';
      } else if (errorMessage.contains('422') ||
          errorMessage.contains('bad syntax') ||
          errorMessage.contains('cannot be fulfilled')) {
        // محاولة البحث بدون fields محددة (سيجلب جميع الحقول)
        AppLogger.warning(
            '⚠️ [search] 422 error detected, attempting fallback without specified fields...');

        // Use valid limit (>= 1) for BridgeCore API
        final fallbackLimit = (limit == null || limit <= 0) ? 1000 : limit;
        final fallbackOffset = offset ?? 0;

        try {
          final fallbackResult = await BridgeCore.instance.odoo.searchRead(
            model: model,
            domain: domain ?? [],
            fields: [], // Empty fields = get all available fields
            limit: fallbackLimit,
            offset: fallbackOffset,
            order: order,
          );

          AppLogger.info(
              '✅ [search] Fallback successful! Found ${fallbackResult.length} records');
          return fallbackResult;
        } catch (fallbackError) {
          AppLogger.error('❌ [search] Fallback also failed: $fallbackError');
          errorMessage =
              'خطأ في البيانات المرسلة (422). يرجى التحقق من صحة المعاملات.';
          AppLogger.error(
              '❌ [search] 422 Error - Domain: ${domain ?? []}, Fields: ${fields ?? []}');
        }
      } else if (errorMessage.contains('500') ||
          errorMessage.contains('Server error')) {
        errorMessage = 'حدث خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقاً.';
      }

      throw Exception(errorMessage);
    } catch (e) {
      // معالجة الأخطاء العامة
      if (e.toString().contains('Name or service not known')) {
        throw Exception(
            'لا يمكن الاتصال بخادم Odoo. يرجى التحقق من إعدادات الخادم.');
      }
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> create({
    required String model,
    required Map<String, dynamic> data,
    Map<String, dynamic>? context,
  }) async {
    try {
      // SDK create returns int (record ID), not the full record
      final recordId = await BridgeCore.instance.odoo.create(
        model: model,
        values: data,
      );

      // Fetch the created record to return full data
      final results = await read(
        model: model,
        ids: [recordId],
      );

      if (results.isEmpty) {
        throw Exception('Failed to create record: $model');
      }

      return results.first;
    } on BridgeCoreException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<Map<String, dynamic>> update({
    required String model,
    required int id,
    required Map<String, dynamic> data,
    Map<String, dynamic>? context,
  }) async {
    try {
      // SDK update returns bool, not the updated record
      await BridgeCore.instance.odoo.update(
        model: model,
        ids: [id],
        values: data,
      );

      // Fetch the updated record to return full data
      final results = await read(
        model: model,
        ids: [id],
      );

      if (results.isEmpty) {
        throw Exception('Failed to update record: $model/$id');
      }

      return results.first;
    } on BridgeCoreException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<bool> delete({
    required String model,
    required int id,
  }) async {
    try {
      await BridgeCore.instance.odoo.delete(
        model: model,
        ids: [id],
      );
      return true;
    } on BridgeCoreException catch (e) {
      throw Exception(e.message);
    }
  }

  // ========== Custom Method Execution ==========

  Future<Map<String, dynamic>> executeMethod({
    required String model,
    required String method,
    List<int>? recordIds,
    List<dynamic>? args,
    Map<String, dynamic>? kwargs,
    Map<String, dynamic>? context,
  }) async {
    if (_apiClient == null) {
      throw Exception('ApiClient is required for executeMethod');
    }

    try {
      // Use tenant-based execute endpoint (بدون system_id)
      final response = await _apiClient!.post(
        ApiConstants.odooExecute,
        queryParameters: {
          'model': model,
          'method': method,
        },
        data: {
          if (recordIds != null) 'record_ids': recordIds,
          if (args != null) 'args': args,
          if (kwargs != null) 'kwargs': kwargs,
          if (context != null) 'context': context,
        },
      );

      return response;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ========== Batch Operations ==========

  Future<List<Map<String, dynamic>>> batch(
    List<Map<String, dynamic>> operations,
  ) async {
    if (_apiClient == null) {
      throw Exception('ApiClient is required for batch operations');
    }

    try {
      final response = await _apiClient!.post(
        ApiConstants.batch,
        data: {'operations': operations},
      );

      return List<Map<String, dynamic>>.from(response['results'] as List);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ========== File Operations ==========

  Future<Map<String, dynamic>> uploadFile(
    String filePath, {
    Map<String, dynamic>? metadata,
  }) async {
    if (_apiClient == null) {
      throw Exception('ApiClient is required for file upload');
    }

    try {
      return await _apiClient!.uploadFile(
        ApiConstants.upload,
        filePath,
        data: metadata,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> downloadFile(int fileId, String savePath) async {
    if (_apiClient == null) {
      throw Exception('ApiClient is required for file download');
    }

    try {
      return await _apiClient!.downloadFile(
        ApiConstants.download(fileId),
        savePath,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> generateReport({
    required String reportType,
    required String format,
    Map<String, dynamic>? params,
  }) async {
    if (_apiClient == null) {
      throw Exception('ApiClient is required for report generation');
    }

    try {
      return await _apiClient!.get(
        ApiConstants.report(reportType),
        queryParameters: {
          'format': format,
          if (params != null) ...params,
        },
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ========== Barcode Operations ==========

  Future<Map<String, dynamic>> lookupBarcode(String barcode) async {
    if (_apiClient == null) {
      throw Exception('ApiClient is required for barcode lookup');
    }

    try {
      return await _apiClient!.get(
        ApiConstants.barcodeLookup(barcode),
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> searchByName(String query) async {
    if (_apiClient == null) {
      throw Exception('ApiClient is required for name search');
    }

    try {
      final response = await _apiClient!.get(
        ApiConstants.barcodeSearch,
        queryParameters: {'name': query},
      );

      return List<Map<String, dynamic>>.from(response['data'] as List);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ========== Helper Methods ==========

  Future<Map<String, dynamic>> readOne({
    required String model,
    required int id,
    List<String>? fields,
  }) async {
    final results = await read(
      model: model,
      ids: [id],
      fields: fields,
    );

    if (results.isEmpty) {
      throw Exception('Record not found: $model/$id');
    }

    return results.first;
  }

  Future<int> count({
    required String model,
    List<dynamic>? domain,
  }) async {
    final response = await search(
      model: model,
      domain: domain,
      limit: 0,
    );

    return response.length;
  }

  Future<Map<String, dynamic>?> searchOne({
    required String model,
    List<dynamic>? domain,
    List<String>? fields,
    String? order,
  }) async {
    final results = await search(
      model: model,
      domain: domain,
      fields: fields,
      limit: 1,
      order: order,
    );

    return results.isEmpty ? null : results.first;
  }
}
