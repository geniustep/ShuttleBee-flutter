import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shuttlebee/core/utils/logger.dart';

/// Analytics Service using Firebase Analytics
/// Tracks user events and app usage
class AnalyticsService {
  static final AnalyticsService instance = AnalyticsService._();
  AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Initialize analytics
  Future<void> initialize() async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(true);
      AppLogger.info('Analytics service initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize analytics: $e');
    }
  }

  // ==================== User Properties ====================

  /// Set user ID
  Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
      AppLogger.debug('User ID set: $userId');
    } catch (e) {
      AppLogger.error('Failed to set user ID: $e');
    }
  }

  /// Set user property
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      AppLogger.debug('User property set: $name = $value');
    } catch (e) {
      AppLogger.error('Failed to set user property: $e');
    }
  }

  // ==================== Screen Tracking ====================

  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      AppLogger.debug('Screen view logged: $screenName');
    } catch (e) {
      AppLogger.error('Failed to log screen view: $e');
    }
  }

  // ==================== Auth Events ====================

  /// Log login event
  Future<void> logLogin(String method) async {
    try {
      await _analytics.logLogin(loginMethod: method);
      AppLogger.debug('Login logged: $method');
    } catch (e) {
      AppLogger.error('Failed to log login: $e');
    }
  }

  /// Log logout event
  Future<void> logLogout() async {
    try {
      await _analytics.logEvent(name: 'logout');
      AppLogger.debug('Logout logged');
    } catch (e) {
      AppLogger.error('Failed to log logout: $e');
    }
  }

  // ==================== Trip Events ====================

  /// Log trip started
  Future<void> logTripStarted({
    required int tripId,
    required String tripType,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'trip_started',
        parameters: {
          'trip_id': tripId,
          'trip_type': tripType,
        },
      );
      AppLogger.debug('Trip started logged: $tripId');
    } catch (e) {
      AppLogger.error('Failed to log trip started: $e');
    }
  }

  /// Log trip completed
  Future<void> logTripCompleted({
    required int tripId,
    required String tripType,
    required int passengersCount,
    required double distance,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'trip_completed',
        parameters: {
          'trip_id': tripId,
          'trip_type': tripType,
          'passengers_count': passengersCount,
          'distance_km': distance,
        },
      );
      AppLogger.debug('Trip completed logged: $tripId');
    } catch (e) {
      AppLogger.error('Failed to log trip completed: $e');
    }
  }

  /// Log trip cancelled
  Future<void> logTripCancelled({
    required int tripId,
    required String reason,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'trip_cancelled',
        parameters: {
          'trip_id': tripId,
          'reason': reason,
        },
      );
      AppLogger.debug('Trip cancelled logged: $tripId');
    } catch (e) {
      AppLogger.error('Failed to log trip cancelled: $e');
    }
  }

  // ==================== Passenger Events ====================

  /// Log passenger boarded
  Future<void> logPassengerBoarded({
    required int tripId,
    required int passengerId,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'passenger_boarded',
        parameters: {
          'trip_id': tripId,
          'passenger_id': passengerId,
        },
      );
    } catch (e) {
      AppLogger.error('Failed to log passenger boarded: $e');
    }
  }

  /// Log passenger absent
  Future<void> logPassengerAbsent({
    required int tripId,
    required int passengerId,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'passenger_absent',
        parameters: {
          'trip_id': tripId,
          'passenger_id': passengerId,
        },
      );
    } catch (e) {
      AppLogger.error('Failed to log passenger absent: $e');
    }
  }

  // ==================== Performance Events ====================

  /// Log app launch
  Future<void> logAppLaunch() async {
    try {
      await _analytics.logAppOpen();
      AppLogger.debug('App launch logged');
    } catch (e) {
      AppLogger.error('Failed to log app launch: $e');
    }
  }

  /// Log error
  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'error_occurred',
        parameters: {
          'error_type': errorType,
          'error_message': errorMessage,
          if (stackTrace != null) 'stack_trace': stackTrace,
        },
      );
    } catch (e) {
      AppLogger.error('Failed to log error: $e');
    }
  }

  // ==================== Custom Events ====================

  /// Log custom event
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
      AppLogger.debug('Custom event logged: $name');
    } catch (e) {
      AppLogger.error('Failed to log custom event: $e');
    }
  }

  // ==================== Report Generation ====================

  /// Log report generated
  Future<void> logReportGenerated({
    required String reportType,
    required String dateRange,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'report_generated',
        parameters: {
          'report_type': reportType,
          'date_range': dateRange,
        },
      );
      AppLogger.debug('Report generation logged: $reportType');
    } catch (e) {
      AppLogger.error('Failed to log report generation: $e');
    }
  }

  // ==================== Manager Actions ====================

  /// Log dashboard view
  Future<void> logDashboardView(String userRole) async {
    try {
      await _analytics.logEvent(
        name: 'dashboard_viewed',
        parameters: {
          'user_role': userRole,
        },
      );
    } catch (e) {
      AppLogger.error('Failed to log dashboard view: $e');
    }
  }

  /// Log analytics view
  Future<void> logAnalyticsView() async {
    try {
      await _analytics.logEvent(name: 'analytics_viewed');
    } catch (e) {
      AppLogger.error('Failed to log analytics view: $e');
    }
  }
}
