import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bhukkdelivery/cards/home/new_order_popup_card.dart';
import 'package:bhukkdelivery/models/dispatch_job.dart';
import 'package:bhukkdelivery/providers/new_order/parcel_order_provider.dart'
    show parcelOrderProvider, NewOrdersState;
import 'package:bhukkdelivery/providers/new_order/medicine_order_provider.dart'
    show medicineOrderProvider;
import 'package:bhukkdelivery/providers/new_order/cab_order_provider.dart'
    show cabOrderProvider;
import 'package:bhukkdelivery/providers/home/master_dashboard_provider.dart';
import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:bhukkdelivery/services/api/dispatch_job_service.dart';

// Per-service lock: prevents the same service type from opening two popup loops.
final _activePopups = <String>{};

/// Starts an order-listening loop for a specific service type.
/// COMPLETELY SEPARATED: Parcel and Cab orders use different providers.
/// If a service toggle is OFF, no orders will come through for that service.
Future<void> showNewOrderPopup(
  BuildContext context,
  WidgetRef ref,
  String serviceType, // 'parcel', 'car_booking', or 'medicine'
) async {
  // Prevent duplicate loops for the same service.
  if (_activePopups.contains(serviceType)) return;
  _activePopups.add(serviceType);

  final container = ProviderScope.containerOf(context);
  StreamSubscription<DispatchJob>? wsSub;
  final jobService = DispatchJobService.instance;
  final orderSignal = StreamController<void>.broadcast(sync: true);

  // Get the correct provider based on service type

  try {
    var lastFetchAt = DateTime.fromMillisecondsSinceEpoch(0);

    // Subscribe to real-time WS jobs
    if (!jobService.isConnected) {
      await jobService.connect();
    }

    wsSub = jobService.jobStream.listen((job) {
      // Check if this job matches our service type
      final jobServiceType = _inferServiceId(job.orderType);
      if (jobServiceType != serviceType) return;

      // Check if service is still online before ingesting
      final dash = container.read(masterDashboardProvider);
      final isOnline = dash.services.any(
        (s) => s.serviceId == serviceType && s.isOnline,
      );
      if (!isOnline) return;

      // Route to the correct notifier
      if (serviceType == 'parcel') {
        container.read(parcelOrderProvider.notifier).ingestDispatchJob(job);
      } else if (serviceType == 'medicine') {
        container.read(medicineOrderProvider.notifier).ingestDispatchJob(job);
      } else {
        container.read(cabOrderProvider.notifier).ingestDispatchJob(job);
      }

      if (!orderSignal.isClosed) orderSignal.add(null);
    });

    // ── Main loop: keep showing orders as long as the service is online ──
    while (context.mounted) {
      // Exit if driver toggled this service offline.
      final dash = container.read(masterDashboardProvider);
      final isOnline = dash.services.any(
        (s) => s.serviceId == serviceType && s.isOnline,
      );
      if (!isOnline) {
        debugPrint(
          '[OrderPopup-$serviceType] Service toggled OFF - stopping popup loop',
        );
        break;
      }

      // Throttled fetch: re-fetch at most once every 15 s.
      final now = DateTime.now();
      if (now.difference(lastFetchAt) >= const Duration(seconds: 15)) {
        lastFetchAt = now;

        // Fetch orders using the service-specific notifier
        if (serviceType == 'parcel') {
          await container.read(parcelOrderProvider.notifier).fetchOrders();
        } else if (serviceType == 'medicine') {
          await container.read(medicineOrderProvider.notifier).fetchOrders();
        } else {
          await container.read(cabOrderProvider.notifier).fetchOrders();
        }
      }

      // Check if we have orders for this specific service
      final hasOrders = serviceType == 'parcel'
          ? container.read(parcelOrderProvider).hasOrders
          : serviceType == 'medicine'
              ? container.read(medicineOrderProvider).hasOrders
              : container.read(cabOrderProvider).hasOrders;

      if (!hasOrders) {
        // No orders yet — wait for a WS push or the next poll cycle.
        try {
          await orderSignal.stream.first.timeout(const Duration(seconds: 5));
        } catch (_) {}
        continue;
      }

      // ── Show the popup ──
      if (!context.mounted) break;

      final wasAccepted = await showGeneralDialog<bool>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withAlpha(100),
        pageBuilder: (ctx, anim1, anim2) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).padding.bottom + 20,
              ),
              child: Material(
                type: MaterialType.transparency,
                child: _NewOrderPopupWrapper(serviceType: serviceType),
              ),
            ),
          );
        },
        transitionBuilder: (ctx, anim1, anim2, child) =>
            FadeTransition(opacity: anim1, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      );

      if (wasAccepted == true) {
        // Delay ensures the dialog pop animation clears the barrier safely
        await Future.delayed(const Duration(milliseconds: 300));
        if (context.mounted) {
          context.push('/home/live_navigation');
        }

        // Order accepted → wait for the delivery to complete, then loop again.
        while (context.mounted) {
          final activeDelivery = container.read(activeDeliveryProvider);
          if (activeDelivery == null) break; // delivery done
          await Future.delayed(const Duration(seconds: 2));
        }

        // Reset the order queue so stale orders are purged.
        lastFetchAt = DateTime.fromMillisecondsSinceEpoch(0);
        if (serviceType == 'parcel') {
          await container.read(parcelOrderProvider.notifier).fetchOrders();
        } else if (serviceType == 'medicine') {
          await container.read(medicineOrderProvider.notifier).fetchOrders();
        } else {
          await container.read(cabOrderProvider.notifier).fetchOrders();
        }
        continue; // loop back to show next order
      }

      // Rejected — short cooldown before showing the next.
      final stillHasOrders = serviceType == 'parcel'
          ? container.read(parcelOrderProvider).hasOrders
          : serviceType == 'medicine'
              ? container.read(medicineOrderProvider).hasOrders
              : container.read(cabOrderProvider).hasOrders;

      if (context.mounted && stillHasOrders) {
        await Future.delayed(const Duration(seconds: 3));
      }
    }
  } finally {
    await wsSub?.cancel();
    await orderSignal.close();
    _activePopups.remove(serviceType);
    debugPrint('[OrderPopup-$serviceType] Popup loop ended');
  }
}

/// Infers service ID from order type for filtering.
String _inferServiceId(String orderType) {
  final t = orderType.trim().toLowerCase();
  
  if (t == 'parcel' || t.contains('parcel')) return 'parcel';
  
  if (t == 'ride' || t == 'car_booking' || t == 'car' || t.contains('ride')) {
    return 'car_booking';
  }
  
  // 💥 Separated back out! Now the medicine loop will handle this exclusively.
  if (t == 'medicine' || t.contains('medicine') || t.contains('pharmacy')) {
    return 'medicine'; 
  }
  
  return orderType.isNotEmpty ? orderType : 'unknown';
}

/// Popup wrapper that uses the correct provider based on service type.
class _NewOrderPopupWrapper extends ConsumerStatefulWidget {
  final String serviceType;

  const _NewOrderPopupWrapper({required this.serviceType});

  @override
  ConsumerState<_NewOrderPopupWrapper> createState() =>
      _NewOrderPopupWrapperState();
}

class _NewOrderPopupWrapperState
    extends ConsumerState<_NewOrderPopupWrapper> {
  Timer? _timer;
  int _secondsRemaining = 29;
  final int _totalSeconds = 29;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        // Auto-reject when time runs out
        _handleReject();
      }
    });
  }

  Future<void> _handleAccept() async {
    _timer?.cancel();

    // Use the correct notifier based on service type.
    if (widget.serviceType == 'parcel') {
      await ref.read(parcelOrderProvider.notifier).acceptOrder();
    } else if (widget.serviceType == 'medicine') {
      await ref.read(medicineOrderProvider.notifier).acceptOrder();
    } else {
      await ref.read(cabOrderProvider.notifier).acceptOrder();
    }

    if (!mounted) return;

    // Only pop as "accepted" if a delivery was actually started.
    final hasDelivery = ref.read(activeDeliveryProvider) != null;
    Navigator.of(context).pop(hasDelivery);
  }

  void _handleReject() {
    // Use the correct notifier based on service type
    if (widget.serviceType == 'parcel') {
      ref.read(parcelOrderProvider.notifier).rejectOrder();
    } else if (widget.serviceType == 'medicine') {
      ref.read(medicineOrderProvider.notifier).rejectOrder();
    } else {
      ref.read(cabOrderProvider.notifier).rejectOrder();
    }

    _timer?.cancel();
    Navigator.of(context).pop(false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the correct provider based on service type
    final NewOrdersState orderState;
    if (widget.serviceType == 'parcel') {
      orderState = ref.watch(parcelOrderProvider);
    } else if (widget.serviceType == 'medicine') {
      orderState = ref.watch(medicineOrderProvider);
    } else {
      orderState = ref.watch(cabOrderProvider);
    }

    if (!orderState.hasOrders) return const SizedBox.shrink();

    return NewOrderPopupCard(
      order: orderState.selectedOrder!,
      countdownSeconds: _secondsRemaining,
      totalSeconds: _totalSeconds,
      onAccept: _handleAccept,
      onReject: _handleReject,
    );
  }
}
