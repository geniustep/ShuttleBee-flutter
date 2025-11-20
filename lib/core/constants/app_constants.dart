/// ثوابت التطبيق العامة
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'ShuttleBee';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String languageKey = 'language';
  static const String themeKey = 'theme';
  static const String firstTimeKey = 'first_time';

  // Hive Boxes
  static const String tripsBoxName = 'trips_box';
  static const String passengersBoxName = 'passengers_box';
  static const String stopsBoxName = 'stops_box';
  static const String vehiclesBoxName = 'vehicles_box';
  static const String settingsBoxName = 'settings_box';
  static const String offlineQueueBoxName = 'offline_queue_box';

  // GPS Configuration
  static const int gpsUpdateIntervalSeconds = 5;
  static const double gpsDistanceFilterMeters = 10.0;

  // Map Configuration
  static const double mapDefaultZoom = 15.0;
  static const double mapDefaultLat = 33.5731;
  static const double mapDefaultLng = -7.5898;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String timeFormat = 'HH:mm';
  static const String displayDateFormat = 'dd/MM/yyyy';
  static const String displayDateTimeFormat = 'dd/MM/yyyy HH:mm';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int phoneNumberLength = 10;

  // Notification Channels
  static const String notificationChannelId = 'shuttlebee_channel';
  static const String notificationChannelName = 'ShuttleBee Notifications';
  static const String notificationChannelDescription =
      'Notifications for trip updates';

  // Trip States
  static const String tripStateDraft = 'draft';
  static const String tripStatePlanned = 'planned';
  static const String tripStateOngoing = 'ongoing';
  static const String tripStateDone = 'done';
  static const String tripStateCancelled = 'cancelled';

  // Trip Line Status
  static const String tripLineStatusNotStarted = 'not_started';
  static const String tripLineStatusAbsent = 'absent';
  static const String tripLineStatusBoarded = 'boarded';
  static const String tripLineStatusDropped = 'dropped';

  // User Roles
  static const String roleDriver = 'driver';
  static const String roleDispatcher = 'dispatcher';
  static const String rolePassenger = 'passenger';
  static const String roleManager = 'manager';

  // Supported Languages
  static const String languageArabic = 'ar';
  static const String languageEnglish = 'en';

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Error Messages
  static const String networkErrorMessage = 'لا يوجد اتصال بالإنترنت';
  static const String serverErrorMessage = 'حدث خطأ في الخادم';
  static const String unknownErrorMessage = 'حدث خطأ غير متوقع';
  static const String validationErrorMessage = 'يرجى التحقق من البيانات المدخلة';
}
