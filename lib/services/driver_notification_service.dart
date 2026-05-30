import 'package:bhukkdelivery/routes/app_router.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// ─────────────────────────────────────────────────────────────────────
/// DriverNotificationService
/// ─────────────────────────────────────────────────────────────────────
/// Handles **transient** Firebase Cloud Messaging notifications:
///   • New delivery job alerts (type = "new_job")
///   • Customer cancellation alerts (type = "customer_cancelled")
///
/// **Ongoing** delivery updates are handled by [BackgroundNotificationService].
/// This service explicitly ignores `ongoing_delivery` payloads to prevent
/// duplicate banners and notification flicker.
///
/// Lifecycle:
///   1. Initialised once in `main.dart` before `runApp`.
///   2. FCM token synced to backend after driver login via [syncToken].
///   3. Foreground messages → local notification banner.
///   4. Background/terminated taps → routes to `/home`.
/// ─────────────────────────────────────────────────────────────────────
class DriverNotificationService {
  DriverNotificationService._();
  static final DriverNotificationService instance =
      DriverNotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // ── Notification Channel IDs ──
  static const _newJobChannelId = 'new_jobs_channel';
  static const _newJobChannelName = 'New Job Alerts';
  static const _cancelChannelId = 'cancellation_alerts_channel';
  static const _cancelChannelName = 'Cancellation Alerts';

  // ── Notification tag IDs (deterministic per-type) ──
  static const _newJobNotifId = 1001;
  static const _cancelNotifId = 1002;

  /// Called once from `main()`.
  Future<void> init() async {
    if (_initialized) return;

    // 1. Request FCM permissions (iOS prompt / Android 13+)
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );

    // 2. Android local-notification plugin reference
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();

    // 3. Create notification channels
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _newJobChannelId,
        _newJobChannelName,
        description: 'High-priority alerts for new delivery/ride requests.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      ),
    );

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _cancelChannelId,
        _cancelChannelName,
        description: 'Alerts when a customer cancels an active order.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      ),
    );

    // 4. Initialise local notifications (for foreground banners)
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@drawable/ic_notif_small'),
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        _handleTap(details.payload);
      },
    );

    // 5. Wire up Firebase listeners
    _setupListeners();

    // 6. Handle the case where the app was opened from a terminated state
    //    via a notification tap.
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleTap(initialMessage.data['order_id']);
    }

    _initialized = true;
  }

  /// Sync the FCM device token to the backend so it can send pushes.
  Future<void> syncToken(Dio api) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        debugPrint("📱 Driver FCM Token: $token");
        await api.patch('/drivers/me/fcm-token', data: {'fcm_token': token});
      }

      // Listen for token refreshes (e.g. after app data clear / reinstall)
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        debugPrint("🔄 FCM Token refreshed: $newToken");
        try {
          await api.patch('/drivers/me/fcm-token', data: {'fcm_token': newToken});
        } catch (e) {
          debugPrint("❌ Failed to sync refreshed token: $e");
        }
      });
    } catch (e) {
      debugPrint("❌ Failed to sync driver token: $e");
    }
  }

  // ──────────────────────────────────────────────────────────────────
  //  FCM LISTENERS
  // ──────────────────────────────────────────────────────────────────

  void _setupListeners() {
    // App is OPEN — show a local banner
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("🔥 Foreground FCM → ${message.data}");
      _showBanner(message);
    });

    // App was BACKGROUNDED → user tapped notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleTap(message.data['order_id']);
    });
  }

  // ──────────────────────────────────────────────────────────────────
  //  SHOW BANNERS
  // ──────────────────────────────────────────────────────────────────

  Future<void> _showBanner(RemoteMessage message) async {
    final type = message.data['type'] ?? 'new_job';

    // ── Ongoing delivery updates → handled by BackgroundNotificationService
    if (type == 'ongoing_delivery') return;

    // ── Customer cancelled ──
    if (type == 'customer_cancelled') {
      await _showCancellationBanner(message);
      return;
    }

    // ── Default: New job alert ──
    final title = message.notification?.title ??
        message.data['title'] ??
        '🚀 New Delivery Request!';
    final body = message.notification?.body ??
        message.data['body'] ??
        'Open app to view and accept.';

    const androidDetails = AndroidNotificationDetails(
      _newJobChannelId,
      _newJobChannelName,
      icon: '@drawable/ic_notif_small',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      autoCancel: true,
      timeoutAfter: 15000,
      color: Color(0xFF12E0FF), // Caby24 brand cyan
      colorized: true,
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
      ticker: 'New delivery available',
    );

    await _localNotifications.show(
      id: _newJobNotifId,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(android: androidDetails),
      payload: message.data['order_id'],
    );
  }

  Future<void> _showCancellationBanner(RemoteMessage message) async {
    final title = message.notification?.title ??
        message.data['title'] ??
        '❌ Order Cancelled';
    final body = message.notification?.body ??
        message.data['body'] ??
        'The customer has cancelled the order.';

    const androidDetails = AndroidNotificationDetails(
      _cancelChannelId,
      _cancelChannelName,
      icon: '@drawable/ic_notif_small',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      autoCancel: true,
      timeoutAfter: 10000,
      color: Color(0xFFEF4444), // Error red
      colorized: true,
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
      ticker: 'Order cancelled by customer',
    );

    await _localNotifications.show(
      id: _cancelNotifId,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(android: androidDetails),
      payload: message.data['order_id'],
    );
  }

  // ──────────────────────────────────────────────────────────────────
  //  TAP HANDLER
  // ──────────────────────────────────────────────────────────────────

  void _handleTap(String? payload) {
    if (payload == null || payload.isEmpty) return;
    debugPrint('🚀 Notification tapped → payload: $payload');

    // Navigate to home; the active-delivery provider or job-stream will
    // pick up the correct state and show live_navigation or job popup.
    router.go('/home');
  }
}
