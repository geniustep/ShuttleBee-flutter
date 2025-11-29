import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shuttlebee/core/services/notification_service.dart';
import 'package:shuttlebee/core/utils/logger.dart';

/// FCM Service - خدمة Firebase Cloud Messaging
class FCMService {
  FCMService._();
  
  static final FCMService instance = FCMService._();
  
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _fcmToken;

  /// تهيئة FCM
  Future<void> initialize() async {
    try {
      // Request permission (iOS)
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        AppLogger.info('FCM permission granted');
      } else {
        AppLogger.warning('FCM permission denied');
        return;
      }

      // Get FCM token
      _fcmToken = await _messaging.getToken();
      AppLogger.info('FCM Token: $_fcmToken');

      // Listen to token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        AppLogger.info('FCM Token refreshed: $newToken');
        // TODO: Send token to backend
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle notification tap (app opened from notification)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check if app was opened from a notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      AppLogger.info('FCM Service initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize FCM Service', e.toString());
    }
  }

  /// معالجة الرسائل في الـ foreground
  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.info('Foreground message received: ${message.messageId}');

    final notification = message.notification;
    if (notification != null) {
      // Show local notification
      NotificationService.instance.showNotification(
        id: message.hashCode,
        title: notification.title ?? 'إشعار جديد',
        body: notification.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// معالجة النقر على الإشعار
  void _handleNotificationTap(RemoteMessage message) {
    AppLogger.info('Notification tapped: ${message.messageId}');
    
    // Handle navigation based on message data
    final data = message.data;
    if (data.containsKey('type')) {
      final type = data['type'] as String;
      switch (type) {
        case 'trip_started':
          // Navigate to trip tracking
          AppLogger.info('Navigate to trip: ${data['trip_id']}');
          break;
        case 'trip_cancelled':
          // Navigate to trips list
          AppLogger.info('Navigate to trips list');
          break;
        default:
          AppLogger.info('Unknown notification type: $type');
      }
    }
  }

  /// الاشتراك في topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      AppLogger.info('Subscribed to topic: $topic');
    } catch (e) {
      AppLogger.error('Failed to subscribe to topic', e.toString());
    }
  }

  /// إلغاء الاشتراك من topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      AppLogger.info('Unsubscribed from topic: $topic');
    } catch (e) {
      AppLogger.error('Failed to unsubscribe from topic', e.toString());
    }
  }

  /// الحصول على FCM token
  String? get fcmToken => _fcmToken;

  /// إرسال token إلى الخادم
  Future<void> sendTokenToServer(String userId) async {
    if (_fcmToken == null) {
      AppLogger.warning('FCM token is null');
      return;
    }

    try {
      // TODO: Send token to backend API
      AppLogger.info('Sending FCM token to server for user: $userId');
      // await apiClient.post('/users/$userId/fcm-token', data: {'token': _fcmToken});
    } catch (e) {
      AppLogger.error('Failed to send FCM token to server', e.toString());
    }
  }
}

/// معالج الرسائل في الخلفية (top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.info('Background message received: ${message.messageId}');
  
  // Handle background message
  final notification = message.notification;
  if (notification != null) {
    // Show local notification
    await NotificationService.instance.showNotification(
      id: message.hashCode,
      title: notification.title ?? 'إشعار جديد',
      body: notification.body ?? '',
      payload: message.data.toString(),
    );
  }
}

