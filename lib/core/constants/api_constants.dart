/// ثوابت الـ API - محدثة لـ Tenant-Based API
/// راجع: https://github.com/geniustep/BridgeCore
class ApiConstants {
  ApiConstants._();

  // Base URLs
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://bridgecore.geniura.com',
  );

  // Note: system_id لم يعد مطلوباً في URL - يتم استخراجه من JWT token
  // Odoo credentials يتم جلبها تلقائياً من قاعدة البيانات
  @Deprecated('system_id is no longer needed in tenant-based API')
  static const String systemId = String.fromEnvironment(
    'SYSTEM_ID',
    defaultValue: 'odoo-prod',
  );

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 60);

  // Token Expiry
  static const int accessTokenExpirySeconds = 1800; // 30 minutes
  static const int refreshTokenExpiryDays = 7;

  // Retry Configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // ========== Odoo Operations (Tenant-Based - بدون system_id) =========

  // Legacy CRUD Operations (deprecated)
  @Deprecated('Use odooRead instead - system_id no longer needed')
  static String read(String systemId) => 'systems/$systemId/read';

  @Deprecated('Use odooCreate instead - system_id no longer needed')
  static String create(String systemId) => 'systems/$systemId/create';

  @Deprecated('Use odooUpdate instead - system_id no longer needed')
  static String update(String systemId, int id) =>
      'systems/$systemId/update/$id';

  @Deprecated('Use odooDelete instead - system_id no longer needed')
  static String delete(String systemId, int id) =>
      'systems/$systemId/delete/$id';

  @Deprecated('Use odooSearchRead instead - system_id no longer needed')
  static String odooSearchReadLegacy(String systemId) =>
      'api/v1/systems/$systemId/odoo/search_read';

  @Deprecated('Use odooExecute instead - system_id no longer needed')
  static String execute(String systemId) => 'systems/$systemId/execute';

  // ========== Batch Operations ==========
  static const String batch = 'api/v1/batch';

  // ========== Odoo Execute ==========
  static const String odooExecute = 'api/v1/odoo/execute';

  // ========== File Operations ==========
  static const String upload = 'api/v1/files/upload';
  static String download(int id) => 'api/v1/files/download/$id';
  static String report(String type) => 'api/v1/files/report/$type';

  // Legacy file operations (deprecated)
  @Deprecated('Use upload instead')
  static String uploadLegacy(String systemId) => 'files/$systemId/upload';

  @Deprecated('Use download instead')
  static String downloadLegacy(String systemId, int id) =>
      'files/$systemId/download/$id';

  @Deprecated('Use report instead')
  static String reportLegacy(String systemId, String type) =>
      'files/$systemId/report/$type';

  // ========== Barcode Operations ==========
  static String barcodeLookup(String barcode) =>
      'api/v1/barcode/lookup/$barcode';
  static const String barcodeSearch = 'api/v1/barcode/search';

  // Legacy barcode operations (deprecated)
  @Deprecated('Use barcodeLookup instead')
  static String barcodeLookupLegacy(String systemId, String barcode) =>
      'barcode/$systemId/lookup/$barcode';

  @Deprecated('Use barcodeSearch instead')
  static String barcodeSearchLegacy(String systemId) =>
      'barcode/$systemId/search';

  // ========== System Connect (قد لا يكون موجوداً في Tenant-Based API) ==========
  /// Note: في Tenant-Based API، لا حاجة لـ connectSystem
  /// لأن Odoo credentials يتم جلبها تلقائياً من قاعدة البيانات
  @Deprecated('connectSystem may not be needed in tenant-based API')
  static String connect(String systemId) => 'systems/$systemId/connect';

  // Headers
  static const String contentTypeJson = 'application/json';
  static const String acceptJson = 'application/json';
  static const String authorizationHeader = 'Authorization';
  static const String acceptLanguageHeader = 'Accept-Language';
}
