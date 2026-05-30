import 'package:bhukkdelivery/models/dispatch_job.dart';
import 'package:bhukkdelivery/models/order_request.dart';
import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:bhukkdelivery/services/api/dispatch_job_service.dart';
import 'package:bhukkdelivery/services/dispatch_order_helper.dart';
import 'package:bhukkdelivery/services/location_service.dart';
import 'package:bhukkdelivery/providers/profile/profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cab/Ride-specific order notifier.
/// Completely separate from parcel orders to ensure toggle-based filtering works correctly.
class CabOrderNotifier extends Notifier<NewOrdersState> {
  final _service = DispatchJobService.instance;

  @override
  NewOrdersState build() {
    return const NewOrdersState();
  }

  /// Check if a job is a valid cab/ride order.
  bool _isCabJob(DispatchJob job) {
    final t = job.orderType.trim().toLowerCase();
    return t == 'ride' ||
        t == 'car_booking' ||
        t == 'car' ||
        t == 'cab' ||
        t.contains('ride');
  }

  /// Add an incoming job (e.g. from WebSocket) into the queue.
  /// Only accepts cab/ride jobs.
  void ingestDispatchJob(DispatchJob job) {
    if (job.id.isEmpty) return;

    // STRICT filtering: Only accept cab/ride jobs
    if (!_isCabJob(job)) return;

    final s = job.status.toUpperCase();
    if (s != 'PENDING' && s != 'AVAILABLE' && s != 'SEARCHING') return;

    final order = _jobToOrderRequest(job);

    // De-dupe by orderId.
    if (state.orders.any((o) => o.orderId == order.orderId)) return;

    // Prepend so the latest order is always first.
    final updated = <OrderRequest>[order, ...state.orders];

    // Protect the app from Out of Memory (OOM) crashes if flooded via WebSocket
    if (updated.length > 20) {
      updated.removeRange(20, updated.length);
    }

    // Automatically select the newest order!
    state = state.copyWith(orders: updated, selectedIndex: 0);
  }

  /// Fetch real cab/ride orders from the backend.
  Future<void> fetchOrders() async {
    double? lat;
    double? lng;
    try {
      final loc = await LocationService.instance.getCurrentPosition();
      if (loc != null) {
        lat = loc.latitude;
        lng = loc.longitude;
      }
    } catch (e) {
      // Ignore if location is unavailable
    }

    // Fetch only cab/ride jobs
    final jobs = await _service.listJobs(
      typeFilter: 'ride',
      driverLat: lat,
      driverLng: lng,
      acceptsRides: true, // EXPLICITLY true
      acceptsParcels: false, // EXPLICITLY false
      limit: 10,
    );

    // Newest-first
    jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final allOrders = <OrderRequest>[];
    final seenIds = <String>{};

    for (final job in jobs) {
      final s = job.status.toUpperCase();
      if (s != 'PENDING' && s != 'AVAILABLE' && s != 'SEARCHING') continue;
      if (job.id.isEmpty || seenIds.contains(job.id)) continue;

      // Double-check it's a cab/ride job
      if (!_isCabJob(job)) continue;

      seenIds.add(job.id);
      allOrders.add(_jobToOrderRequest(job));

      if (allOrders.length >= 6) break;
    }

    state = NewOrdersState(orders: allOrders, selectedIndex: 0);
  }

  void selectOrder(int index) {
    if (index >= 0 && index < state.orders.length) {
      state = state.copyWith(selectedIndex: index);
    }
  }

  Future<void> acceptOrder() async {
    final order = state.selectedOrder;
    if (order == null) return;

    // Accept on backend — await so 403 interceptor can fire before we proceed.
    final driverId = ref.read(profileProvider)?.id;
    final result = await _service.acceptJob(order.orderId, driverId: driverId);

    // If backend rejected (null = failed / 403), do NOT start a ghost delivery.
    // The global 403 interceptor will handle suspension routing automatically.
    if (result == null) return;

    // Transfer to active delivery with real coordinates.
    ref
        .read(activeDeliveryProvider.notifier)
        .startDelivery(orderRequestToActiveDelivery(order));

    state = const NewOrdersState();
  }

  void rejectOrder() {
    if (!state.hasOrders) return;

    final order = state.selectedOrder;
    if (order != null) {
      _service.rejectJob(order.orderId);
    }

    final updatedOrders = List<OrderRequest>.from(state.orders)
      ..removeAt(state.selectedIndex);

    final newIndex = state.selectedIndex >= updatedOrders.length
        ? (updatedOrders.isEmpty ? 0 : updatedOrders.length - 1)
        : state.selectedIndex;

    state = NewOrdersState(orders: updatedOrders, selectedIndex: newIndex);
  }

  OrderRequest _jobToOrderRequest(DispatchJob job) {
    return dispatchJobToOrderRequest(
      job,
      storeNameOverride: 'Pickup Point',
      cuisineOverride: 'Intercity Ride',
      itemsOverride: 'Ride to ${job.dropAddress.split(',').first}',
    );
  }
}
