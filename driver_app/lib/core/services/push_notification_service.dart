import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../services/sentry_service.dart';

/// Top-level handler for background/terminated-state FCM messages.
///
/// Must be a top-level function (not a class method) because the Flutter
/// engine runs it in an isolate that has no access to widget state.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized by the time this runs (the plugin
  // calls Firebase.initializeApp internally for background isolates).
  if (kDebugMode) {
    debugPrint('[FCM-bg] ${message.messageId}: ${message.data}');
  }
}

/// Manages Firebase Cloud Messaging for the driver app.
///
/// Responsibilities:
///   - Request notification permissions (Android 13+ / iOS)
///   - Obtain and refresh the FCM registration token
///   - Show local notifications for foreground messages
///   - Expose a callback for notification taps so the app can navigate
///
/// Usage:
/// ```dart
/// final push = PushNotificationService.instance;
/// await push.initialize(onNotificationTap: (deliveryId) { ... });
/// final token = await push.getToken();
/// ```
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Callback invoked when the user taps a notification.
  /// Receives the delivery ID extracted from the FCM payload.
  void Function(String deliveryId)? _onNotificationTap;

  /// Whether [initialize] has already run.
  bool _initialized = false;

  // ── Android notification channel ───────────────────────────────────────

  static const _channelId = 'driver_orders';
  static const _channelName = 'طلبات التوصيل'; // "Delivery orders" in Arabic
  static const _channelDescription = 'إشعارات الطلبات الجديدة والتحديثات';

  static const _androidChannel = AndroidNotificationChannel(
    _channelId,
    _channelName,
    description: _channelDescription,
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  // ── Public API ─────────────────────────────────────────────────────────

  /// Call once during app startup, after [Firebase.initializeApp].
  ///
  /// [onNotificationTap] is invoked with the delivery ID when the user
  /// taps a notification (from foreground, background, or terminated state).
  Future<void> initialize({
    void Function(String deliveryId)? onNotificationTap,
  }) async {
    if (_initialized) return;
    _initialized = true;
    _onNotificationTap = onNotificationTap;

    // 1. Request permission (no-op on Android < 13)
    await _requestPermission();

    // 2. Create the high-importance Android channel
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_androidChannel);
    }

    // 3. Initialize flutter_local_notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false, // We handle this via FirebaseMessaging
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // 4. Register the background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 5. Listen for foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 6. Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);

    // 7. Check if the app was opened from a terminated-state notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationOpen(initialMessage);
    }

    // 8. Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      if (kDebugMode) debugPrint('[FCM] Token refreshed: $newToken');
      // The caller should re-save the token. We expose it via the callback
      // registered on token refresh, and also via getToken().
      _onTokenRefresh?.call(newToken);
    });

    addBreadcrumb(
      message: 'PushNotificationService initialized',
      category: 'push',
    );
  }

  /// Callback for token refresh events. Set by [onTokenRefresh].
  void Function(String token)? _onTokenRefresh;

  /// Register a listener that fires whenever the FCM token is rotated.
  ///
  /// Typically used to re-save the token to Supabase.
  void onTokenRefresh(void Function(String token) callback) {
    _onTokenRefresh = callback;
  }

  /// Returns the current FCM registration token, or `null` if unavailable.
  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      if (kDebugMode) debugPrint('[FCM] Token: $token');
      return token;
    } catch (e, st) {
      reportError(e, stackTrace: st, hint: 'FCM getToken');
      return null;
    }
  }

  /// Delete the FCM token (e.g. on logout).
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      if (kDebugMode) debugPrint('[FCM] Token deleted');
    } catch (e, st) {
      reportError(e, stackTrace: st, hint: 'FCM deleteToken');
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────

  Future<void> _requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: true, // iOS: announce via Siri
        criticalAlert: false,
      );

      if (kDebugMode) {
        debugPrint('[FCM] Permission: ${settings.authorizationStatus}');
      }

      // On iOS, set foreground presentation options so notifications
      // appear even when the app is open.
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e, st) {
      reportError(e, stackTrace: st, hint: 'FCM requestPermission');
    }
  }

  /// Show a local notification when an FCM message arrives while the app
  /// is in the foreground.
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      debugPrint('[FCM-fg] ${message.messageId}: ${message.data}');
    }
    addBreadcrumb(
      message: 'FCM foreground message',
      category: 'push',
      data: {'messageId': message.messageId, ...message.data},
    );

    final notification = message.notification;
    if (notification == null) return;

    // Encode the data payload into the notification so we can read it on tap.
    final payload = jsonEncode(message.data);

    await _localNotifications.show(
      message.hashCode,
      notification.title ?? 'طلب جديد',
      notification.body ?? '',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  /// Called when the user taps an FCM notification that opened the app from
  /// background state.
  void _handleNotificationOpen(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('[FCM-open] ${message.messageId}: ${message.data}');
    }
    addBreadcrumb(
      message: 'Notification opened app',
      category: 'push',
      data: message.data,
    );

    final deliveryId = message.data['delivery_id'] as String?;
    if (deliveryId != null && _onNotificationTap != null) {
      _onNotificationTap!(deliveryId);
    }
  }

  /// Called when the user taps a local notification (foreground case).
  void _onLocalNotificationTap(NotificationResponse response) {
    if (kDebugMode) {
      debugPrint('[LocalNotification-tap] payload: ${response.payload}');
    }

    if (response.payload == null || response.payload!.isEmpty) return;

    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      final deliveryId = data['delivery_id'] as String?;
      if (deliveryId != null && _onNotificationTap != null) {
        _onNotificationTap!(deliveryId);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[LocalNotification-tap] parse error: $e');
    }
  }
}
