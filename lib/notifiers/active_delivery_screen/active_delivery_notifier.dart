import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bhukkdelivery/models/active_delivery.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bhukkdelivery/services/api/api_config.dart';
import 'package:bhukkdelivery/services/api/dispatch_job_service.dart';
import 'package:bhukkdelivery/services/live_tracking_service.dart';
import 'package:bhukkdelivery/providers/parcel/parcel_rider_provider.dart';
import 'package:bhukkdelivery/services/background_notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// ─────────────────────────────────────────────────────────────────────
/// ActiveDeliveryNotifier
/// ─────────────────────────────────────────────────────────────────────
/// Central state manager for the driver's current active delivery.
///
/// Notification lifecycle:
///   • startDelivery()  → persistent notification appears instantly
///   • state changes    → notification content auto-updates
///   • completeDelivery() → notification cleared
///   • cancelDelivery()   → notification cleared
///   • customer cancels   → "Cancelled" notification → auto-clear after 5s
/// ─────────────────────────────────────────────────────────────────────
class ActiveDeliveryNotifier extends Notifier<ActiveDelivery?> {
  final _jobService = DispatchJobService.instance;
  final _bgNotif = BackgroundNotificationService.instance;

  String? _lastOtpError;
  String? get lastOtpError => _lastOtpError;

  StreamSubscription<Map<String, dynamic>>? _trackingSub;
  StreamSubscription<Map<String, dynamic>>? _globalSub;

  Future<bool> _updateStatusWithFallback({
    required String jobId,
    required List<String> statusCandidates,
    required String otp,
  }) async {
    _lastOtpError = null;
    for (final status in statusCandidates) {
      final result = await _jobService.updateJobStatus(
        jobId,
        newStatus: status,
        otp: otp,
      );

      if (result.ok) return true;
      _lastOtpError =
          result.errorMessage ?? 'OTP rejected (status ${result.statusCode})';
    }
    return false;
  }

  @override
  ActiveDelivery? build() {
    ref.onDispose(() {
      _stopTracking();
    });
    return null;
  }

  /// ─── State setter override ──
  /// Automatically pushes notification updates whenever state changes.
  @override
  set state(ActiveDelivery? value) {
    super.state = value;
    if (value != null) {
      _bgNotif.updateNotification(
        statusLabel: value.statusLabel,
        actionLabel: value.actionButtonLabel,
        storeName: value.storeName,
        isPickup: value.isPickupPhase,
        address: value.isPickupPhase ? value.storeAddress : value.customerAddress,
      );
    }
    // Note: we do NOT call stopAndClear here when value == null,
    // because the caller (completeDelivery / cancelDelivery / customer cancel)
    // handles the notification teardown explicitly.
  }

  // ══════════════════════════════════════════════════════════════════
  //  START DELIVERY
  // ══════════════════════════════════════════════════════════════════

  void startDelivery(ActiveDelivery delivery) {
    final context = rootNavigatorKey.currentContext;
    final currentAddress =
        delivery.isPickupPhase ? delivery.storeAddress : delivery.customerAddress;

    // 1. INSTANT notification + background service boot (single call)
    if (context != null) {
      _bgNotif.startWithDelivery(
        router: GoRouter.of(context),
        statusLabel: delivery.statusLabel,
        actionLabel: delivery.actionButtonLabel,
        storeName: delivery.storeName,
        address: currentAddress,
        isPickup: delivery.isPickupPhase,
      );
    }

    // 2. Set state → triggers the `set state` override for future updates
    state = delivery;

    // 3. Start streaming GPS to the parcel backend if we have a bridge ID
    if (delivery.externalOrderId.isNotEmpty) {
      LiveTrackingService.instance.startTracking(delivery.externalOrderId);
    }

    // 4. Cache the active order ID in SharedPreferences
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('active_order_id', delivery.orderId);
      debugPrint('[ActiveDeliveryNotifier] Cached active order ID: ${delivery.orderId}');
    });

    // 5. Listen for CUSTOMER_CANCELLED from the TRACKING room
    _trackingSub?.cancel();
    _trackingSub = LiveTrackingService.instance.eventStream.listen((data) async {
      final event = data['event'];
      if (event == 'CUSTOMER_CANCELLED') {
        debugPrint('🚨 Customer cancelled (via Tracking WS)!');
        _handleCustomerCancellation(delivery);
      } else if (event == 'WS_CLOSED') {
        debugPrint('📡 Tracking connection closed — checking order status');
        final job = await _jobService.getJob(delivery.orderId);
        if (job != null && job.status.toLowerCase() == 'cancelled') {
          debugPrint('🚩 Order confirmed cancelled via fallback fetch');
          _handleCustomerCancellation(delivery);
        }
      }
    });

    // 6. Listen for CUSTOMER_CANCELLED from the GLOBAL channel
    _globalSub?.cancel();
    _globalSub = _jobService.cancelStream.listen((data) {
      if (data['event'] == 'CUSTOMER_CANCELLED' &&
          (data['order_id'] == delivery.orderId ||
              data['job_id'] == delivery.orderId)) {
        debugPrint('🚨 Customer cancelled (via Global WS)!');
        _handleCustomerCancellation(delivery);
      }
    });
  }

  // ══════════════════════════════════════════════════════════════════
  //  CUSTOMER CANCELLATION HANDLER
  // ══════════════════════════════════════════════════════════════════

  void _handleCustomerCancellation(ActiveDelivery delivery) {
    final context = rootNavigatorKey.currentContext;

    // 1. Show a "Cancelled" notification that auto-clears after 5s
    _bgNotif.showCancelledAndStop(storeName: delivery.storeName);

    // 2. Show a highly visible alert to the driver
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Alert: The customer cancelled the order. Returning to map."),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    // 3. Wipe Riverpod state
    ref.read(parcelRiderStatusProvider.notifier).clearJob();

    // 4. Yank back to dashboard
    if (context != null && context.mounted) {
      GoRouter.of(context).go('/home');
    }

    // 5. Clean up
    _stopTracking();
    _clearActiveOrderCache();
    super.state = null; // bypass our override — notification already handled
  }

  // ══════════════════════════════════════════════════════════════════
  //  STATUS PROGRESSION
  // ══════════════════════════════════════════════════════════════════

  void markPaymentCollected() {
    if (state != null) {
      state = state!.copyWith(paymentStatus: 'paid');
    }
  }

  void advanceStatus() {
    if (state == null) return;
    final current = state!;

    // OTP-gated transitions should NOT be advanced directly
    if (current.requiresOtp) return;

    switch (current.status) {
      case DeliveryStatus.headingToStore:
        state = current.copyWith(status: DeliveryStatus.arrivedAtStore);
        _updateStatusWithFallback(jobId: current.orderId, statusCandidates: const ['arrived', 'ARRIVED'], otp: '');
        break;
      case DeliveryStatus.arrivedAtStore:
        state = current.copyWith(status: DeliveryStatus.pickedUp);
        _updateStatusWithFallback(jobId: current.orderId, statusCandidates: const ['picked_up', 'PICKED_UP'], otp: '');
        break;
      case DeliveryStatus.pickedUp:
        state = current.copyWith(status: DeliveryStatus.enRoute);
        _updateStatusWithFallback(jobId: current.orderId, statusCandidates: const ['en_route', 'EN_ROUTE'], otp: '');
        break;
      case DeliveryStatus.enRoute:
        state = current.copyWith(status: DeliveryStatus.arriving);
        _updateStatusWithFallback(jobId: current.orderId, statusCandidates: const ['arriving', 'ARRIVING'], otp: '');
        break;
      case DeliveryStatus.arriving:
        completeDelivery();
        break;
      case DeliveryStatus.delivered:
        completeDelivery();
        break;
    }
  }

  /// Verify OTP and advance status.
  /// Uses backend OTPs when provided.
  /// Also updates backend status via /drivers/jobs/{id}/status.
  Future<bool> verifyOtp(String enteredOtp) async {
    if (state == null) return false;
    var current = state!;

    _lastOtpError = null;

    if (enteredOtp.length != 4) return false;

    final demoBypass = kDebugMode && ApiConfig.demoOtpBypass;
    if (demoBypass) {
      if (current.status == DeliveryStatus.arrivedAtStore) {
        state = current.copyWith(status: DeliveryStatus.pickedUp);
        return true;
      }
      if (current.status == DeliveryStatus.arriving) {
        state = current.copyWith(status: DeliveryStatus.delivered);
        _stopTracking();
        return true;
      }
    }

    // For Ride/Parcel, prefer backend-generated OTPs.
    // If they aren't present on the current delivery, refresh once from server.
    if ((current.isRide || current.isParcel) &&
        current.currentExpectedOtp.isEmpty) {
      final job = await _jobService.getJob(current.orderId);
      if (job != null) {
        final updated = current.copyWith(
          pickupOtp: job.pickupOtp ?? '',
          deliveryOtp: job.dropOtp ?? '',
          encodedPolyline: job.encodedPolyline,
        );
        state = updated;
        current = updated;
      }
    }

    final expected = current.currentExpectedOtp;
    if ((current.isRide || current.isParcel) && expected.isEmpty) {
      _lastOtpError = 'OTP not available from backend';
      return false;
    }
    if (expected.isNotEmpty && enteredOtp != expected) {
      _lastOtpError = 'OTP does not match';
      return false;
    }

    if (current.status == DeliveryStatus.arrivedAtStore) {
      final ok = await _updateStatusWithFallback(
        jobId: current.orderId,
        statusCandidates: const ['picked_up', 'PICKED_UP'],
        otp: enteredOtp,
      );
      if (!ok) return false;
      state = current.copyWith(status: DeliveryStatus.pickedUp);
      return true;
    }

    if (current.status == DeliveryStatus.arriving) {
      final ok = await _updateStatusWithFallback(
        jobId: current.orderId,
        statusCandidates: const ['delivered', 'DELIVERED'],
        otp: enteredOtp,
      );
      if (!ok) return false;
      
      if (current.isCashOnDelivery) {
        state = current.copyWith(status: DeliveryStatus.delivered);
        _stopTracking();
      } else {
        // Prepaid / UPI - complete immediately!
        ref.read(parcelRiderStatusProvider.notifier).clearJob();
        _stopTracking();
        _clearActiveOrderCache();
        _bgNotif.stopAndClear();
        super.state = null;
      }
      return true;
    }

    return false;
  }

  // ══════════════════════════════════════════════════════════════════
  //  CANCEL / COMPLETE
  // ══════════════════════════════════════════════════════════════════

  /// Cancel active delivery via backend API.
  /// Returns (ok, errorMessage) so the UI can react.
  Future<({bool ok, String? errorMessage})> cancelDelivery() async {
    if (state == null) return (ok: false, errorMessage: 'No active delivery');
    final current = state!;

    // Block cancellation after driver has arrived
    if (current.status != DeliveryStatus.headingToStore) {
      return (ok: false, errorMessage: 'Cannot cancel after arriving');
    }

    // Get the driver's Firebase UID for the cancel request
    final driverUid = FirebaseAuth.instance.currentUser?.uid;

    final result = await _jobService.cancelOrder(
      current.orderId,
      driverId: driverUid,
    );

    // If cancellation succeeded OR if it triggered a 403 suspension,
    // the order is no longer assigned to this driver. Wipe the local cache.
    if (result.ok || result.statusCode == 403) {
      ref.read(parcelRiderStatusProvider.notifier).clearJob();
      _stopTracking();
      _clearActiveOrderCache();
      _bgNotif.stopAndClear();
      super.state = null;
      
      if (result.ok) {
        return (ok: true, errorMessage: null);
      }
    }

    return (ok: false, errorMessage: result.errorMessage);
  }

  Future<void> completeDelivery() async {
    if (state != null) {
      final current = state!;
      await _updateStatusWithFallback(
        jobId: current.orderId,
        statusCandidates: const ['delivered', 'DELIVERED'],
        otp: '',
      );
    }
    
    _stopTracking();
    _clearActiveOrderCache();
    _bgNotif.stopAndClear();
    super.state = null;
  }

  // ══════════════════════════════════════════════════════════════════
  //  CLEANUP
  // ══════════════════════════════════════════════════════════════════

  void _stopTracking() {
    _trackingSub?.cancel();
    _trackingSub = null;
    _globalSub?.cancel();
    _globalSub = null;
    LiveTrackingService.instance.stopTracking();
    _jobService.disconnect();
  }

  void _clearActiveOrderCache() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('active_order_id');
      debugPrint('[ActiveDeliveryNotifier] Wiped active order ID from local cache.');
    });
  }
}
