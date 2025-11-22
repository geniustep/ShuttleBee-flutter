import 'package:bridgecore_flutter/bridgecore_flutter.dart';
import 'package:shuttlebee/core/config/app_config.dart';
import 'package:shuttlebee/core/constants/api_constants.dart';
import 'package:shuttlebee/core/network/api_client.dart';

/// BridgeCore service wrapper for Odoo integration using bridgecore_flutter SDK.
class BridgeCoreService {
  BridgeCoreService({
    String? systemId,
    ApiClient? apiClient,
  })  : _systemId = systemId ?? AppConfig.systemId,
        _apiClient = apiClient;

  String _systemId;
  final ApiClient? _apiClient;

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
        // تجاهل خطأ logout إذا لم يكن هناك session
      }

      // Use SDK for tenant-based login
      // Note: في Tenant-Based API، لا حاجة لإرسال url و database
      // لأنها مخزنة في قاعدة البيانات للـ tenant
      // SDK يتعامل مع tenant login تلقائياً
      final session = await BridgeCore.instance.auth.login(
        email: username, // Tenant-based API يستخدم email
        password: password,
      );

      // SDK يحفظ التوكنات تلقائياً، لكن نحتاج لحفظها أيضاً في SecureStorage
      // للتوافق مع الكود القديم الذي يتحقق من SecureStorage
      if (_apiClient != null) {
        // حفظ التوكنات في SecureStorage عبر ApiClient storage
        // (ApiClient يستخدم SecureStorage في AuthInterceptor)
        // لكن SDK يحفظها في مكانه الخاص، لذا نحتاج للتأكد من التزامن
      }

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
        errorMessage = 'لا يمكن الاتصال بالخادم. تأكد من أن الخادم يعمل على ${AppConfig.apiBaseUrl}';
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
      // Use SDK for logout
      await BridgeCore.instance.auth.logout();
      return {'success': true};
    } on BridgeCoreException catch (e) {
      throw Exception(e.message);
    } catch (e) {
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
  /// هذه الدالة موجودة للتوافق مع الكود القديم فقط ولا تفعل شيئاً
  @Deprecated('Not used in Tenant-Based API - all operations go through bridgecore.geniura.com')
  Future<Map<String, dynamic>> connectSystem({
    required String url, // غير مستخدم - للتوافق فقط
    required String database, // غير مستخدم - للتوافق فقط
    required String username, // غير مستخدم - للتوافق فقط
    required String password, // غير مستخدم - للتوافق فقط
    String systemType = 'odoo',
  }) async {
    // في Tenant-Based API، لا حاجة لـ connectSystem
    // لأن Odoo credentials يتم جلبها تلقائياً من قاعدة البيانات
    // كل العمليات تمر عبر bridgecore.geniura.com
    return {
      'success': true,
      'message': 'System connection handled automatically in tenant-based API. All operations go through bridgecore.geniura.com',
    };
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    // SDK قد لا يوفر getCurrentUser مباشرة
    // نستخدم ApiClient كـ fallback
    if (_apiClient == null) {
      throw Exception('ApiClient is required for getCurrentUser');
    }

    try {
      // Use tenant-based me endpoint
      return await _apiClient!.get(ApiConstants.authTenantMe);
    } catch (e) {
      throw Exception(e.toString());
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
      return await BridgeCore.instance.odoo.searchRead(
        model: model,
        domain: domain ?? [],
        fields: fields ?? [],
        limit: limit ?? 0,
        offset: offset ?? 0,
        order: order,
        useSmartFallback: true, // Enable smart fallback for invalid fields
      );
    } on BridgeCoreException catch (e) {
      // تحسين رسائل الخطأ
      String errorMessage = e.message;
      
      // معالجة أخطاء Odoo connection
      if (errorMessage.contains('Name or service not known') ||
          errorMessage.contains('Odoo authentication failed')) {
        errorMessage = 'لا يمكن الاتصال بخادم Odoo. يرجى التحقق من إعدادات الخادم.';
      } else if (errorMessage.contains('401') || 
                  errorMessage.contains('authentication failed')) {
        errorMessage = 'فشل المصادقة مع Odoo. يرجى التحقق من بيانات الاعتماد.';
      } else if (errorMessage.contains('500') || 
                  errorMessage.contains('Server error')) {
        errorMessage = 'حدث خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقاً.';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      // معالجة الأخطاء العامة
      if (e.toString().contains('Name or service not known')) {
        throw Exception('لا يمكن الاتصال بخادم Odoo. يرجى التحقق من إعدادات الخادم.');
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
