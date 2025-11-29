import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shuttlebee/core/utils/logger.dart';

/// Notification Service - إدارة الإشعارات المحلية
class NotificationService {
  NotificationService._();
  
  static final NotificationService instance = NotificationService._();
  
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  bool _initialized = false;

  /// تهيئة خدمة الإشعارات
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Android settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _initialized = true;
      AppLogger.info('NotificationService initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize NotificationService', e.toString());
    }
  }

  /// معالجة النقر على الإشعار
  void _onNotificationTapped(NotificationResponse response) {
    AppLogger.info('Notification tapped: ${response.payload}');
    // يمكن إضافة navigation هنا بناءً على payload
  }

  /// طلب صلاحيات الإشعارات (iOS)
  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();

    final result = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    return result ?? true; // Android doesn't need runtime permissions
  }

  /// عرض إشعار بسيط
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'shuttlebee_channel',
      'ShuttleBee Notifications',
      channelDescription: 'Notifications for trip updates and alerts',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );
      AppLogger.info('Notification shown: $title');
    } catch (e) {
      AppLogger.error('Failed to show notification', e.toString());
    }
  }

  /// إشعار بدء الرحلة
  Future<void> notifyTripStarted({
    required int tripId,
    required String tripName,
  }) async {
    await showNotification(
      id: tripId,
      title: 'بدأت الرحلة 🚌',
      body: 'رحلة "$tripName" بدأت الآن',
      payload: 'trip:$tripId',
    );
  }

  /// إشعار اقتراب الوصول
  Future<void> notifyApproachingStop({
    required int tripId,
    required String tripName,
    required String stopName,
    required int minutesAway,
  }) async {
    await showNotification(
      id: tripId + 1000,
      title: 'الحافلة تقترب 📍',
      body: 'ستصل الحافلة إلى "$stopName" خلال $minutesAway دقيقة',
      payload: 'trip:$tripId',
    );
  }

  /// إشعار وصول إلى نقطة توقف
  Future<void> notifyArrived({
    required int tripId,
    required String tripName,
    required String stopName,
  }) async {
    await showNotification(
      id: tripId + 2000,
      title: 'وصلت الحافلة ✅',
      body: 'وصلت الحافلة إلى "$stopName"',
      payload: 'trip:$tripId',
    );
  }

  /// إشعار تأخير الرحلة
  Future<void> notifyTripDelayed({
    required int tripId,
    required String tripName,
    required int delayMinutes,
  }) async {
    await showNotification(
      id: tripId + 3000,
      title: 'تأخير في الرحلة ⏰',
      body: 'رحلة "$tripName" متأخرة بحوالي $delayMinutes دقيقة',
      payload: 'trip:$tripId',
    );
  }

  /// إشعار إلغاء الرحلة
  Future<void> notifyTripCancelled({
    required int tripId,
    required String tripName,
  }) async {
    await showNotification(
      id: tripId + 4000,
      title: 'تم إلغاء الرحلة ❌',
      body: 'رحلة "$tripName" تم إلغاؤها',
      payload: 'trip:$tripId',
    );
  }

  /// إشعار انتهاء الرحلة
  Future<void> notifyTripCompleted({
    required int tripId,
    required String tripName,
  }) async {
    await showNotification(
      id: tripId + 5000,
      title: 'انتهت الرحلة 🎉',
      body: 'رحلة "$tripName" انتهت بنجاح',
      payload: 'trip:$tripId',
    );
  }

  /// إلغاء إشعار معين
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// إلغاء جميع الإشعارات
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}

