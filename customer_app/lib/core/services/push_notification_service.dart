import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../router/app_router.dart';
import 'sentry_service.dart';

/// Top-level handler for background/terminated-state FCM messages.
///
/// Must be a top-level function (not a class method) for Firebase to invoke it.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized before this runs.
  if (kDebugMode) {
    debugPrint('[FCM] Background message: ${message.messageId}');
  }
}

/// Manages Firebase Cloud Messaging lifecycle for the customer app.
///
/// Responsibilities:
/// - Request notification permission
/// - Obtain & persist FCM token in Supabase `users.fcm_token`
/// - Listen for token refresh
/// - Show local notifications for foreground messages
/// - Route notification taps to the correct screen
class PushNotificationService {
  PushNotificationService._();

  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();
  static StreamSubscription<RemoteMessage>? _foregroundSub;
  static StreamSubscription<String>? _tokenRefreshSub;

  /// Android notification channel for order updates.
  static const _orderChannel = AndroidNotificationChannel(
    'order_updates',
    'تحديثات الطلبات',
    description: 'اشعارات حالة الطلب والتوصيل',
    importance: Importance.high,
  );

  /// Android notification channel for promotions.
  static const _promoChannel = AndroidNotificationChannel(
    'promotions',
    'العروض والتخفيضات',
    description: 'عروض وخصومات خاصة',
    importance: Importance.defaultImportance,
  );

  // ---------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------

  /// Call once after Firebase.initializeApp() and Supabase init.
  static Future<void> initialize() async {
    // Register the background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Set up local notifications plugin (Android + iOS)
    await _initLocalNotifications();

    // Create Android notification channels
    await _createNotificationChannels();

    // Request permission (iOS will show a dialog, Android 13+ likewise)
    await _requestPermission();

    // Get initial token and save it
    await _handleToken();

    // Listen for token refresh
    _tokenRefreshSub = _messaging.onTokenRefresh.listen(_saveTokenToSupabase);

    // Foreground messages -> show local notification
    _foregroundSub = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );

    // Notification tap while app is in background (not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was launched via a notification tap (terminated state)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    addBreadcrumb(message: 'Push notifications initialized', category: 'fcm');
  }

  /// Clean up subscriptions. Call on logout or app dispose.
  static void dispose() {
    _foregroundSub?.cancel();
    _tokenRefreshSub?.cancel();
  }

  /// Remove FCM token from Supabase on logout.
  static Future<void> clearToken() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await Supabase.instance.client
            .from('users')
            .update({'fcm_token': null})
            .eq('id', userId);
      }
      await _messaging.deleteToken();
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'FCM clearToken');
    }
  }

  // ---------------------------------------------------------------
  // Permission
  // ---------------------------------------------------------------

  static Future<void> _requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );

      if (kDebugMode) {
        debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');
      }

      // iOS: set foreground presentation options
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: false, // we handle foreground ourselves via local notifications
        badge: true,
        sound: false,
      );
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'FCM requestPermission');
    }
  }

  // ---------------------------------------------------------------
  // Token management
  // ---------------------------------------------------------------

  static Future<void> _handleToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveTokenToSupabase(token);
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'FCM getToken');
    }
  }

  static Future<void> _saveTokenToSupabase(String token) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      await Supabase.instance.client
          .from('users')
          .update({'fcm_token': token})
          .eq('id', userId);

      if (kDebugMode) {
        debugPrint('[FCM] Token saved for user $userId');
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'FCM saveToken');
    }
  }

  // ---------------------------------------------------------------
  // Local notifications setup
  // ---------------------------------------------------------------

  static Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false, // we request via Firebase
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );
  }

  static Future<void> _createNotificationChannels() async {
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_orderChannel);
      await androidPlugin.createNotificationChannel(_promoChannel);
    }
  }

  // ---------------------------------------------------------------
  // Foreground message handling
  // ---------------------------------------------------------------

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      debugPrint('[FCM] Foreground message: ${message.data}');
    }

    final notification = message.notification;
    if (notification == null) return;

    // Pick channel based on message type
    final type = message.data['type'] as String? ?? '';
    final channelId = _channelForType(type);

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId == _orderChannel.id
              ? _orderChannel.name
              : _promoChannel.name,
          channelDescription: channelId == _orderChannel.id
              ? _orderChannel.description
              : _promoChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  /// Map notification type to a channel ID.
  static String _channelForType(String type) {
    switch (type) {
      case 'order_status':
      case 'delivery_update':
        return _orderChannel.id;
      case 'promotion':
      case 'offer':
        return _promoChannel.id;
      default:
        return _orderChannel.id;
    }
  }

  // ---------------------------------------------------------------
  // Notification tap handling
  // ---------------------------------------------------------------

  /// Called when user taps a notification while app is in background.
  static void _handleNotificationTap(RemoteMessage message) {
    _navigateFromPayload(message.data);
  }

  /// Called when user taps a local notification (foreground-shown).
  static void _onLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      _navigateFromPayload(data);
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] Failed to parse tap payload: $e');
    }
  }

  /// Route to the correct screen based on notification data.
  static void _navigateFromPayload(Map<String, dynamic> data) {
    final type = data['type'] as String? ?? '';
    final orderId = data['order_id'] as String?;

    switch (type) {
      case 'order_status':
      case 'delivery_update':
        if (orderId != null && orderId.isNotEmpty) {
          AppRouter.router.push('/orders/$orderId/track');
        } else {
          AppRouter.router.go('/orders');
        }
      case 'promotion':
      case 'offer':
        // Navigate to home where promotions are displayed
        AppRouter.router.go('/home');
      default:
        if (orderId != null && orderId.isNotEmpty) {
          AppRouter.router.push('/orders/$orderId');
        }
    }
  }
}
