import 'dart:async';
import 'package:bhukkdelivery/models/dispatch_job.dart';
import 'package:bhukkdelivery/models/order_request.dart';
import 'package:bhukkdelivery/providers/ambulance/ambulance_rider_provider.dart';
import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:bhukkdelivery/services/api/dispatch_job_service.dart';
import 'package:bhukkdelivery/services/dispatch_order_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AmbulanceOrderPopupState {
  final OrderRequest? currentOrder;
  final int countdownSeconds;
  final int totalSeconds;
  final bool isVisible;

  const AmbulanceOrderPopupState({
    this.currentOrder,
    this.countdownSeconds = 0,
    this.totalSeconds = 30,
    this.isVisible = false,
  });

  double get progress => totalSeconds > 0 ? countdownSeconds / totalSeconds : 0;
}

class AmbulanceOrderPopupNotifier extends Notifier<AmbulanceOrderPopupState> {
  Timer? _countdownTimer;
  Timer? _pollTimer;
  StreamSubscription<DispatchJob>? _wsSub;
  final _service = DispatchJobService.instance;

  @override
  AmbulanceOrderPopupState build() {
    ref.listen(ambulanceRiderStatusProvider, (prev, isOnline) {
      if (isOnline && prev != true) {
        _startListening();
      } else if (!isOnline) {
        _cancelAll();
        state = const AmbulanceOrderPopupState();
      }
    });

    // If this notifier is created after the user already toggled online,
    // the listener above won't fire (no state change). Start immediately.
    if (ref.read(ambulanceRiderStatusProvider)) {
      Future.microtask(_startListening);
    }
    ref.onDispose(() {
      _countdownTimer?.cancel();
      _pollTimer?.cancel();
      _wsSub?.cancel();
    });
    return const AmbulanceOrderPopupState();
  }

  void _startListening() {
    // Ensure WebSocket is connected for real-time jobs.
    _service.connect(typeFilter: 'ambulance');

    _fetchAndShowNextOrder();
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (ref.read(ambulanceRiderStatusProvider) && !state.isVisible) {
        _fetchAndShowNextOrder();
      }
    });
    _wsSub?.cancel();
    _wsSub = _service.jobStream.listen((job) {
      if (!state.isVisible && job.orderType.toLowerCase() == 'ambulance') {
        _showOrder(
          dispatchJobToOrderRequest(
            job,
            storeNameOverride: 'Emergency Request',
            cuisineOverride: 'Ambulance',
          ),
        );
      }
    });
  }

  Future<void> _fetchAndShowNextOrder() async {
    final jobs = await _service.listJobs(typeFilter: 'ambulance', limit: 1);
    if (jobs.isNotEmpty) {
      _showOrder(
        dispatchJobToOrderRequest(
          jobs.first,
          storeNameOverride: 'Emergency Request',
          cuisineOverride: 'Ambulance',
        ),
      );
    }
  }

  void _showOrder(OrderRequest order) {
    _countdownTimer?.cancel();
    const total = 30;
    state = AmbulanceOrderPopupState(
      currentOrder: order,
      countdownSeconds: total,
      totalSeconds: total,
      isVisible: true,
    );
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.countdownSeconds <= 1) {
        timer.cancel();
        _onTimeout();
        return;
      }
      state = AmbulanceOrderPopupState(
        currentOrder: state.currentOrder,
        countdownSeconds: state.countdownSeconds - 1,
        totalSeconds: state.totalSeconds,
        isVisible: state.isVisible,
      );
    });
  }

  void _onTimeout() {
    state = const AmbulanceOrderPopupState();
    if (ref.read(ambulanceRiderStatusProvider)) {
      Future.delayed(const Duration(seconds: 5), () {
        if (ref.read(ambulanceRiderStatusProvider) && !state.isVisible) {
          _fetchAndShowNextOrder();
        }
      });
    }
  }

  void _cancelAll() {
    _countdownTimer?.cancel();
    _pollTimer?.cancel();
    _wsSub?.cancel();
    _service.disconnect();
  }

  void acceptOrder() {
    final order = state.currentOrder;
    if (order == null) return;
    _cancelAll();
    _service.acceptJob(order.orderId, driverId: 'current_driver');
    ref
        .read(activeDeliveryProvider.notifier)
        .startDelivery(orderRequestToActiveDelivery(order));
    state = const AmbulanceOrderPopupState();
    _startListening();
  }

  void rejectOrder() {
    final order = state.currentOrder;
    _cancelAll();
    if (order != null) {
      _service.rejectJob(order.orderId);
    }
    state = const AmbulanceOrderPopupState();
    if (ref.read(ambulanceRiderStatusProvider)) _startListening();
  }
}
