import 'package:logger/logger.dart';
import 'package:shuttlebee/core/config/app_config.dart';

/// Logger للتطبيق
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    filter: ProductionFilter(),
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    level: AppConfig.isDebugMode ? Level.debug : Level.warning,
  );

  /// Log debug message
  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (AppConfig.enableLogging) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log info message
  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (AppConfig.enableLogging) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log warning message
  static void warning(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    if (AppConfig.enableLogging) {
      _logger.w(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log error message
  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log fatal message
  static void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Log network request
  static void logRequest(String method, String url, {dynamic data}) {
    if (AppConfig.enableLogging) {
      debug('→ $method $url', data);
    }
  }

  /// Log network response
  static void logResponse(
    String method,
    String url,
    int statusCode, {
    dynamic data,
  }) {
    if (AppConfig.enableLogging) {
      if (statusCode >= 200 && statusCode < 300) {
        debug('← $method $url [$statusCode]', data);
      } else {
        error('← $method $url [$statusCode]', data);
      }
    }
  }

  /// Log network error
  static void logNetworkError(String method, String url, dynamic error) {
    AppLogger.error('✗ $method $url', error);
  }
}
