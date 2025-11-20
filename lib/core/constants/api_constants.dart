/// ثوابت الـ API
class ApiConstants {
  ApiConstants._();

  // Base URLs
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

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

  // BridgeCore Endpoints
  static const String authLogin = '/auth/login';
  static const String authLogout = '/auth/logout';
  static const String authRefresh = '/auth/refresh';
  static const String authMe = '/auth/me';

  // CRUD Operations
  static String read(String systemId) => '/systems/$systemId/read';
  static String create(String systemId) => '/systems/$systemId/create';
  static String update(String systemId, int id) =>
      '/systems/$systemId/update/$id';
  static String delete(String systemId, int id) =>
      '/systems/$systemId/delete/$id';
  static String search(String systemId) => '/systems/$systemId/search';

  // Custom Methods
  static String execute(String systemId) => '/systems/$systemId/execute';

  // Batch Operations
  static const String batch = '/batch';

  // Files
  static String upload(String systemId) => '/files/$systemId/upload';
  static String download(String systemId, int id) =>
      '/files/$systemId/download/$id';
  static String report(String systemId, String type) =>
      '/files/$systemId/report/$type';

  // Barcode
  static String barcodeLookup(String systemId, String barcode) =>
      '/barcode/$systemId/lookup/$barcode';
  static String barcodeSearch(String systemId) => '/barcode/$systemId/search';

  // Headers
  static const String contentTypeJson = 'application/json';
  static const String acceptJson = 'application/json';
  static const String authorizationHeader = 'Authorization';
  static const String acceptLanguageHeader = 'Accept-Language';
}
