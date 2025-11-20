import 'package:shuttlebee/core/config/app_config.dart';
import 'package:shuttlebee/core/constants/api_constants.dart';
import 'package:shuttlebee/core/network/api_client.dart';

/// خدمة BridgeCore للتعامل مع Odoo
class BridgeCoreService {
  BridgeCoreService({
    required ApiClient apiClient,
    String? systemId,
  })  : _apiClient = apiClient,
        _systemId = systemId ?? AppConfig.systemId;

  final ApiClient _apiClient;
  final String _systemId;

  // ========== Authentication ==========

  /// تسجيل الدخول
  Future<Map<String, dynamic>> login({
    required String url,
    required String database,
    required String username,
    required String password,
    String systemType = 'odoo',
    String systemVersion = '18.0',
  }) async {
    return _apiClient.post(
      ApiConstants.authLogin,
      data: {
        'system_credentials': {
          'system_type': systemType,
          'system_version': systemVersion,
          'credentials': {
            'url': url,
            'database': database,
            'username': username,
            'password': password,
          },
        },
      },
    );
  }

  /// تسجيل الخروج
  Future<Map<String, dynamic>> logout() async {
    return _apiClient.post(ApiConstants.authLogout);
  }

  /// الحصول على بيانات المستخدم الحالي
  Future<Map<String, dynamic>> getCurrentUser() async {
    return _apiClient.get(ApiConstants.authMe);
  }

  // ========== CRUD Operations ==========

  /// قراءة سجلات (Read)
  Future<List<Map<String, dynamic>>> read({
    required String model,
    List<int>? ids,
    List<String>? fields,
    int? limit,
    int? offset,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.read(_systemId),
      queryParameters: {
        'model': model,
        if (ids != null) 'ids': ids,
        if (fields != null) 'fields': fields,
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      },
    );

    return List<Map<String, dynamic>>.from(response['data'] as List);
  }

  /// البحث (Search)
  Future<List<Map<String, dynamic>>> search({
    required String model,
    List<dynamic>? domain,
    List<String>? fields,
    int? limit,
    int? offset,
    String? order,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.search(_systemId),
      queryParameters: {'model': model},
      data: {
        if (domain != null) 'domain': domain,
        if (fields != null) 'fields': fields,
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
        if (order != null) 'order': order,
      },
    );

    return List<Map<String, dynamic>>.from(response['data'] as List);
  }

  /// إنشاء سجل (Create)
  Future<Map<String, dynamic>> create({
    required String model,
    required Map<String, dynamic> data,
    Map<String, dynamic>? context,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.create(_systemId),
      queryParameters: {'model': model},
      data: {
        'data': data,
        if (context != null) 'context': context,
      },
    );

    return response['data'] as Map<String, dynamic>;
  }

  /// تحديث سجل (Update)
  Future<Map<String, dynamic>> update({
    required String model,
    required int id,
    required Map<String, dynamic> data,
    Map<String, dynamic>? context,
  }) async {
    final response = await _apiClient.put(
      ApiConstants.update(_systemId, id),
      queryParameters: {'model': model},
      data: {
        'data': data,
        if (context != null) 'context': context,
      },
    );

    return response['data'] as Map<String, dynamic>;
  }

  /// حذف سجل (Delete)
  Future<bool> delete({
    required String model,
    required int id,
  }) async {
    final response = await _apiClient.delete(
      ApiConstants.delete(_systemId, id),
      queryParameters: {'model': model},
    );

    return response['success'] as bool? ?? false;
  }

  // ========== Custom Method Execution ==========

  /// تنفيذ method مخصص
  Future<Map<String, dynamic>> executeMethod({
    required String model,
    required String method,
    List<int>? recordIds,
    List<dynamic>? args,
    Map<String, dynamic>? kwargs,
    Map<String, dynamic>? context,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.execute(_systemId),
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
  }

  // ========== Batch Operations ==========

  /// تنفيذ عدة عمليات دفعة واحدة
  Future<List<Map<String, dynamic>>> batch(
    List<Map<String, dynamic>> operations,
  ) async {
    final response = await _apiClient.post(
      ApiConstants.batch,
      data: {'operations': operations},
    );

    return List<Map<String, dynamic>>.from(response['results'] as List);
  }

  // ========== File Operations ==========

  /// رفع ملف
  Future<Map<String, dynamic>> uploadFile(
    String filePath, {
    Map<String, dynamic>? metadata,
  }) async {
    return _apiClient.uploadFile(
      ApiConstants.upload(_systemId),
      filePath,
      data: metadata,
    );
  }

  /// تحميل ملف
  Future<void> downloadFile(int fileId, String savePath) async {
    return _apiClient.downloadFile(
      ApiConstants.download(_systemId, fileId),
      savePath,
    );
  }

  /// توليد تقرير
  Future<Map<String, dynamic>> generateReport({
    required String reportType,
    required String format,
    Map<String, dynamic>? params,
  }) async {
    return _apiClient.get(
      ApiConstants.report(_systemId, reportType),
      queryParameters: {
        'format': format,
        if (params != null) ...params,
      },
    );
  }

  // ========== Barcode Operations ==========

  /// البحث عن باركود
  Future<Map<String, dynamic>> lookupBarcode(String barcode) async {
    return _apiClient.get(
      ApiConstants.barcodeLookup(_systemId, barcode),
    );
  }

  /// البحث عن منتج بالاسم
  Future<List<Map<String, dynamic>>> searchByName(String query) async {
    final response = await _apiClient.get(
      ApiConstants.barcodeSearch(_systemId),
      queryParameters: {'name': query},
    );

    return List<Map<String, dynamic>>.from(response['data'] as List);
  }

  // ========== Helper Methods ==========

  /// قراءة سجل واحد بالـ ID
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

  /// عد السجلات
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

  /// البحث عن سجل واحد
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
