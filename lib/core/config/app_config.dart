import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shuttlebee/core/utils/logger.dart';

/// تكوين التطبيق من Environment Variables
class AppConfig {
  AppConfig._();

  /// تحميل المتغيرات البيئية
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  // API Configuration
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://bridgecore.geniura.com';

  static String get systemId => dotenv.env['SYSTEM_ID'] ?? 'odoo-prod';

  // Odoo Configuration
  // Note: في Tenant-Based API، هذه القيم غير مستخدمة
  // لأن كل العمليات تمر عبر bridgecore.geniura.com
  // Odoo credentials يتم جلبها تلقائياً من قاعدة البيانات للـ tenant
  @Deprecated(
      'Not used in Tenant-Based API - all operations go through bridgecore.geniura.com')
  static String get odooUrl =>
      dotenv.env['ODOO_URL'] ?? 'https://demo.odoo.com';

  @Deprecated(
      'Not used in Tenant-Based API - all operations go through bridgecore.geniura.com')
  static String get odooDatabase => dotenv.env['ODOO_DATABASE'] ?? 'demo';

  @Deprecated(
      'Not used in Tenant-Based API - all operations go through bridgecore.geniura.com')
  static String get odooUsername => dotenv.env['ODOO_USERNAME'] ?? 'admin';

  @Deprecated(
      'Not used in Tenant-Based API - all operations go through bridgecore.geniura.com')
  static String get odooPassword => dotenv.env['ODOO_PASSWORD'] ?? 'admin';

  // Token Configuration
  static int get accessTokenExpiry =>
      int.tryParse(dotenv.env['ACCESS_TOKEN_EXPIRY'] ?? '1800') ?? 1800;

  static int get refreshTokenExpiry =>
      int.tryParse(dotenv.env['REFRESH_TOKEN_EXPIRY'] ?? '604800') ?? 604800;

  // App Configuration
  static String get appName => dotenv.env['APP_NAME'] ?? 'ShuttleBee';

  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';

  // GPS Configuration
  static int get gpsUpdateIntervalSeconds =>
      int.tryParse(dotenv.env['GPS_UPDATE_INTERVAL_SECONDS'] ?? '5') ?? 5;

  static double get gpsDistanceFilterMeters =>
      double.tryParse(dotenv.env['GPS_DISTANCE_FILTER_METERS'] ?? '10.0') ??
      10.0;

  // Map Configuration
  static double get mapDefaultZoom =>
      double.tryParse(dotenv.env['MAP_DEFAULT_ZOOM'] ?? '15.0') ?? 15.0;

  static double get mapDefaultLat =>
      double.tryParse(dotenv.env['MAP_DEFAULT_LAT'] ?? '33.5731') ?? 33.5731;

  static double get mapDefaultLng =>
      double.tryParse(dotenv.env['MAP_DEFAULT_LNG'] ?? '-7.5898') ?? -7.5898;

  // Notification Configuration
  static String get fcmServerKey =>
      dotenv.env['FCM_SERVER_KEY'] ?? 'your_fcm_server_key';

  // Debug Mode
  static bool get isDebugMode =>
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';

  static bool get enableLogging =>
      dotenv.env['ENABLE_LOGGING']?.toLowerCase() == 'true';

  // Development Role Override (for testing purposes only)
  // Set to 'dispatcher', 'driver', 'passenger', or 'manager' to force a role in debug mode
  static String? get debugRoleOverride =>
      dotenv.env['DEBUG_ROLE_OVERRIDE']?.toLowerCase();

  /// طباعة التكوين الحالي (للتطوير فقط)
  static void printConfig() {
    if (isDebugMode) {
      AppLogger.info('=== ShuttleBee Configuration ===');
      AppLogger.info('API Base URL: $apiBaseUrl');
      AppLogger.info('System ID: $systemId');
      AppLogger.info('Odoo URL: $odooUrl');
      AppLogger.info('Odoo Database: $odooDatabase');
      AppLogger.info('App Name: $appName');
      AppLogger.info('App Version: $appVersion');
      AppLogger.info('Debug Mode: $isDebugMode');
      AppLogger.info(
          'Debug Role Override: ${debugRoleOverride ?? "none (will use dispatcher as default)"}');
      AppLogger.info('Enable Logging: $enableLogging');
      AppLogger.info('================================');
    }
  }
}
