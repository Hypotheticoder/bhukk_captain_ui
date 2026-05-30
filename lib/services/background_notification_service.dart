import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ─────────────────────────────────────────────────────────────────────
/// BackgroundNotificationService
/// ─────────────────────────────────────────────────────────────────────
/// Manages the **persistent, ongoing** notification shown during an
/// active delivery.
///
///  ┌──────────┐   accept   ┌───────────────┐   status   ┌───────────┐
///  │ No notif │ ─────────▶ │  Persistent   │ ─────────▶ │ Cleared   │
///  │          │            │  Notification  │  complete  │           │
///  └──────────┘            │  (ongoing)     │  /cancel   └───────────┘
///                          └───────────────┘
///
/// Lifecycle:
///   1. Driver accepts a job → [startWithDelivery] fires an instant
///      notification from the main thread and boots the background isolate.
///   2. As delivery status changes → [updateNotification] pushes new
///      text to the isolate (queued if isolate isn't ready yet).
///   3. Delivery completed/cancelled → [stopAndClear] kills the isolate
///      and wipes the notification + SharedPreferences cache.
///   4. Customer cancels → [showCancelledAndStop] posts a final
///      "Order Cancelled" notification and then tears down.
///
/// The background isolate runs a 2-second heartbeat that re-posts the
/// notification, making it resilient to user swipe-dismissal.
///
/// Notification is styled with:
///   • Custom `ic_notif_active` icon (delivery steering-wheel)
///   • Caby24 brand cyan colour accent
///   • `ongoing: true` flag so it can't be swiped away
///   • Public visibility for lock-screen
///   • No sound/vibration on updates (only first show)
/// ─────────────────────────────────────────────────────────────────────

// ══════════════════════════════════════════════════════════════════════
//  BACKGROUND ISOLATE ENTRY POINT
// ══════════════════════════════════════════════════════════════════════
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final flnp = FlutterLocalNotificationsPlugin();

  const androidInit = AndroidInitializationSettings('@drawable/ic_notif_active');
  const initSettings = InitializationSettings(android: androidInit);

  await flnp.initialize(
    settings: initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.payload == 'active_delivery_route') {
        service.invoke('notification_clicked');
      }
    },
  );

  // ── Cached state for the heartbeat to re-post ──
  String nTitle = 'Caby24 Captain — Active Delivery';
  String nContent = 'Delivery in progress';
  String nStatus = 'Active Delivery';
  String nStoreName = '';
  String nAction = '';
  String nAddress = '';
  bool nIsCancelled = false;

  // Track previous status so we only vibrate on actual changes
  String prevStatus = '';

  // ── Helper: build content string ──
  String buildContent() {
    if (nIsCancelled) return '❌ This order was cancelled by the customer.';
    final target = nStoreName.isNotEmpty ? nStoreName : 'Location';
    final lines = <String>[];
    if (nAddress.isNotEmpty) lines.add('📍 $target: $nAddress');
    if (nAction.isNotEmpty) lines.add('▶ Next: $nAction');
    return lines.isNotEmpty ? lines.join('\n') : 'Delivery in progress';
  }

  // ── Helper: post / re-post the notification ──
  // [alertOnce] = true → vibrate + sound once (status change).
  // [alertOnce] = false (default) → silent re-post (heartbeat).
  Future<void> postNotification({bool alertOnce = false}) async {
    if (service is AndroidServiceInstance) {
      await service.setForegroundNotificationInfo(
        title: nTitle,
        content: nContent,
      );
    }
    await flnp.show(
      id: BackgroundNotificationService.notifId,
      title: nTitle,
      body: nContent,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          BackgroundNotificationService.channelId,
          BackgroundNotificationService.channelName,
          icon: '@drawable/ic_notif_active',
          ongoing: !nIsCancelled,
          autoCancel: nIsCancelled,
          // Heartbeat re-posts use LOW importance so Android does NOT
          // re-trigger the channel's default vibration/sound pattern.
          // Status changes use MAX so the driver feels the buzz.
          importance: alertOnce ? Importance.max : Importance.low,
          priority: alertOnce ? Priority.high : Priority.low,
          showWhen: false,
          enableVibration: alertOnce,
          playSound: alertOnce,
          onlyAlertOnce: true, // Android-native: suppress repeated alerts
          silent: !alertOnce, // Explicitly silence heartbeat re-posts
          color: nIsCancelled
              ? const Color(0xFFEF4444) // Error red
              : const Color(0xFF12E0FF), // Brand cyan
          colorized: true,
          category: AndroidNotificationCategory.navigation,
          visibility: NotificationVisibility.public,
          ticker: nIsCancelled ? 'Order cancelled' : null,
        ),
      ),
      payload: 'active_delivery_route',
    );
  }

  // ── 1. Restore from SharedPreferences (survives app kill) ──
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();

    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('bg_status')) {
      nStatus = prefs.getString('bg_status') ?? 'Active Delivery';
      nAction = prefs.getString('bg_action') ?? '';
      nStoreName = prefs.getString('bg_store') ?? '';
      nAddress = prefs.getString('bg_address') ?? '';
      prevStatus = nStatus;
      nTitle = 'Caby24 Captain — $nStatus';
      nContent = buildContent();
      await postNotification(); // silent restore
    }
  }

  // ── 2. Tell main thread we are alive ──
  service.invoke('request_initial_state');

  bool isStopping = false;

  // ── 3. Stop listener ──
  service.on('stopService').listen((event) async {
    isStopping = true;
    // Cancel the notification before stopping
    await flnp.cancel(id: BackgroundNotificationService.notifId);
    service.stopSelf();
  });

  // ── 4. Update listener ──
  service.on('updateNotification').listen((event) async {
    if (event == null) return;

    nIsCancelled = event['cancelled'] == true;
    final newStatus = event['status'] as String? ?? 'Active Delivery';
    nAction = event['action'] as String? ?? '';
    nStoreName = event['store'] as String? ?? '';
    nAddress = event['address'] as String? ?? '';

    // Detect if the status actually changed
    final statusChanged = newStatus != prevStatus || nIsCancelled;
    nStatus = newStatus;
    prevStatus = newStatus;

    nTitle = nIsCancelled
        ? '❌ Caby24 Captain — Order Cancelled'
        : 'Caby24 Captain — $nStatus';
    nContent = buildContent();

    // Only vibrate once when the status changes (or on cancellation)
    await postNotification(alertOnce: statusChanged);
  });

  // ── 5. HEARTBEAT: Smart re-post to survive swipe-dismiss ──
  // Checks if the notification is still in the system tray.
  // If it was swiped away, re-posts it silently. This avoids vibration spam!
  Timer.periodic(const Duration(seconds: 3), (_) async {
    if (!nIsCancelled && !isStopping) {
      final activeNotifs = await flnp.getActiveNotifications();
      final isShowing = activeNotifs.any((n) => n.id == BackgroundNotificationService.notifId);
      if (!isShowing) {
        await postNotification(); // silent restore
      }
    }
  });
}

// ══════════════════════════════════════════════════════════════════════
//  MAIN-THREAD SINGLETON
// ══════════════════════════════════════════════════════════════════════
class BackgroundNotificationService {
  BackgroundNotificationService._();
  static final BackgroundNotificationService instance =
      BackgroundNotificationService._();

  static const String channelId = 'active_delivery_channel_v2';
  static const String channelName = 'Active Delivery Updates';
  static const int notifId = 888;

  final _service = FlutterBackgroundService();

  bool _initialized = false;
  bool _running = false;

  // Queued payload: if updateNotification is called before the service
  // is fully running, we stash it here and flush it once the isolate
  // signals readiness.
  Map<String, dynamic>? _pendingPayload;

  Stream<Map<String, dynamic>?> get onIsolateReady =>
      _service.on('request_initial_state');

  /// Pre-create the notification channel (call early, e.g. from main).
  Future<void> requestPermissionsAndCreateChannel() async {
    if (kIsWeb) return;
    final flnp = FlutterLocalNotificationsPlugin();
    const channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: 'Persistent notification for active deliveries.',
      importance: Importance.max,
    );

    final androidPlugin = flnp
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.createNotificationChannel(channel);
  }

  /// Configure the background service (call once after login/splash).
  Future<void> initialize(
    GoRouter router, {
    String initialTitle = 'Caby24 Captain — Active Delivery',
    String initialContent = 'Preparing delivery...',
  }) async {
    if (kIsWeb) return;
    if (_initialized) return;
    _initialized = true;

    // Click handler
    _service.on('notification_clicked').listen((event) {
      debugPrint('🚀 Persistent notification tapped → live_navigation');
      router.push('/home/live_navigation');
    });

    // Isolate ready handler — flush any queued payload
    _service.on('request_initial_state').listen((_) {
      debugPrint('🔗 Background isolate signalled ready');
      if (_pendingPayload != null) {
        debugPrint('📤 Flushing queued notification payload');
        _service.invoke('updateNotification', _pendingPayload!);
        _pendingPayload = null;
      }
    });

    const channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: 'Persistent notification for active deliveries.',
      importance: Importance.max,
    );

    final flnp = FlutterLocalNotificationsPlugin();
    final androidPlugin = flnp
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.createNotificationChannel(channel);

    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: channelId,
        initialNotificationTitle: initialTitle,
        initialNotificationContent: initialContent,
        foregroundServiceNotificationId: notifId,
        foregroundServiceTypes: [AndroidForegroundType.location],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
      ),
    );
  }

  /// Boot the background isolate.
  Future<void> startService() async {
    if (kIsWeb) return;
    if (_running) return;
    _running = true;
    await _service.startService();
  }

  /// ─────────────────────────────────────────────────────────────
  /// HIGH-LEVEL API — Called from ActiveDeliveryNotifier
  /// ─────────────────────────────────────────────────────────────

  /// Called the instant the driver accepts a job.
  /// Fires a notification immediately from the main thread (no isolate
  /// boot delay), then starts the background service.
  Future<void> startWithDelivery({
    required GoRouter router,
    required String statusLabel,
    required String actionLabel,
    required String storeName,
    required String address,
    required bool isPickup,
  }) async {
    // 1. INSTANT banner from main thread
    await fireInstantNotification(
      statusLabel: statusLabel,
      storeName: storeName,
      actionLabel: actionLabel,
      address: address,
    );

    // 2. Init + start background service
    final targetName = storeName.isNotEmpty ? storeName : 'Location';
    await initialize(
      router,
      initialTitle: 'Caby24 Captain — $statusLabel',
      initialContent: '📍 $targetName: $address\n▶ Next: $actionLabel',
    );
    await startService();

    // 3. Queue the full payload for the isolate
    await updateNotification(
      statusLabel: statusLabel,
      actionLabel: actionLabel,
      storeName: storeName,
      isPickup: isPickup,
      address: address,
    );
  }

  /// Update the persistent notification content.
  Future<void> updateNotification({
    required String statusLabel,
    required String actionLabel,
    required String storeName,
    required bool isPickup,
    required String address,
  }) async {
    if (kIsWeb) return;

    // Persist to disk so the isolate can self-heal after app kill
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bg_status', statusLabel);
    await prefs.setString('bg_action', actionLabel);
    await prefs.setString('bg_store', storeName);
    await prefs.setString('bg_address', address);

    final payload = {
      'status': statusLabel,
      'action': actionLabel,
      'store': storeName,
      'isPickup': isPickup,
      'address': address,
      'cancelled': false,
    };

    if (_running) {
      _service.invoke('updateNotification', payload);
    } else {
      debugPrint('⏳ Service not running yet, queuing notification payload');
      _pendingPayload = payload;
    }
  }

  /// Show a "Customer Cancelled" notification, then tear down.
  Future<void> showCancelledAndStop({
    required String storeName,
  }) async {
    if (kIsWeb) return;

    // Show the cancellation state via isolate
    if (_running) {
      _service.invoke('updateNotification', {
        'status': 'Order Cancelled',
        'action': '',
        'store': storeName,
        'address': '',
        'cancelled': true,
      });
    } else {
      // Fallback: fire directly from main thread
      final flnp = FlutterLocalNotificationsPlugin();
      await flnp.show(
        id: notifId,
        title: '❌ Caby24 Captain — Order Cancelled',
        body: 'The customer has cancelled the order.',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            icon: '@drawable/ic_notif_active',
            ongoing: false,
            autoCancel: true,
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false,
            enableVibration: true,
            playSound: true,
            color: Color(0xFFEF4444),
            colorized: true,
            category: AndroidNotificationCategory.message,
            visibility: NotificationVisibility.public,
          ),
        ),
        payload: 'active_delivery_route',
      );
    }

    // Auto-clear after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      stopAndClear();
    });
  }

  /// Stop the background service and clear the notification + cache.
  Future<void> stopAndClear() async {
    if (kIsWeb) return;
    _running = false;
    _pendingPayload = null;

    // Wipe cached data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bg_status');
    await prefs.remove('bg_action');
    await prefs.remove('bg_store');
    await prefs.remove('bg_address');

    // Cancel the notification immediately from main thread
    final flnp = FlutterLocalNotificationsPlugin();
    await flnp.cancel(id: notifId);

    // Tell the isolate to stop itself
    _service.invoke('stopService');
  }

  /// Fire a notification INSTANTLY from the main thread.
  /// This does NOT wait for the background isolate to boot.
  Future<void> fireInstantNotification({
    required String statusLabel,
    required String storeName,
    required String actionLabel,
    required String address,
  }) async {
    if (kIsWeb) return;

    final targetName = storeName.isNotEmpty ? storeName : 'Location';

    final flnp = FlutterLocalNotificationsPlugin();
    await flnp.show(
      id: notifId,
      title: 'Caby24 Captain — $statusLabel',
      body: '📍 $targetName: $address\n▶ Next: $actionLabel',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          icon: '@drawable/ic_notif_active',
          ongoing: true,
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
          enableVibration: true,
          playSound: true,
          color: Color(0xFF12E0FF),
          colorized: true,
          category: AndroidNotificationCategory.navigation,
          visibility: NotificationVisibility.public,
          ticker: 'Active delivery started',
        ),
      ),
      payload: 'active_delivery_route',
    );
  }
}
