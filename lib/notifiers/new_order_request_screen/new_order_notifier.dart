import 'package:bhukkdelivery/models/dispatch_job.dart';
import 'package:bhukkdelivery/models/order_request.dart';
import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:bhukkdelivery/services/api/dispatch_job_service.dart';
import 'package:bhukkdelivery/services/dispatch_order_helper.dart';
import 'package:bhukkdelivery/services/location_service.dart';
import 'package:bhukkdelivery/providers/profile/profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Notifier ──
class NewOrderNotifier extends Notifier<NewOrdersState> {
  final _service = DispatchJobService.instance;

  @override
  NewOrdersState build() {
    return const NewOrdersState();
  }

  String _inferServiceTypeFromJob(DispatchJob job) {
    final t = job.orderType.trim().toLowerCase();
    if (t == 'parcel' || t.contains('parcel')) return 'parcel';
    if (t == 'ride' || t == 'car_booking' || t == 'car' || t.contains('ride')) {
      return 'car_booking';
    }
    // Default to raw type when unknown.
    return job.orderType.isNotEmpty ? job.orderType : 'parcel';
  }

  /// Add an incoming job (e.g. from WebSocket) into the queue.
  /// Keeps existing popup UI/UX, just fills it in real-time.
  void ingestDispatchJob(DispatchJob job, {String? serviceTypeOverride}) {
    if (job.id.isEmpty) return;

    final s = job.status.toUpperCase();
    if (s != 'PENDING' && s != 'AVAILABLE' && s != 'SEARCHING') return;

    final serviceType = serviceTypeOverride ?? _inferServiceTypeFromJob(job);
    final order = _jobToOrderRequest(job, serviceType);

    // De-dupe by orderId.
    if (state.orders.any((o) => o.orderId == order.orderId)) return;

    // Prepend so the latest order is always first.
    final updated = <OrderRequest>[order, ...state.orders];

    // Automatically select the newest order!
    state = state.copyWith(orders: updated, selectedIndex: 0);
  }

  /// Fetch real orders for the given service types from the backend.
  Future<void> fetchOrdersForServices(List<String> serviceTypes) async {
    if (serviceTypes.isEmpty) {
      state = const NewOrdersState();
      return;
    }

    final allOrders = <OrderRequest>[];
    final seenIds = <String>{};

    // Determine toggles from the requested list.
    final acceptsRides =
        serviceTypes.contains('car_booking') || serviceTypes.contains('ride');
    final acceptsParcels = serviceTypes.contains('parcel');

    // Attempt to get the current location
    double? lat;
    double? lng;
    try {
      final loc = await LocationService.instance.getCurrentPosition();
      if (loc != null) {
        lat = loc.latitude;
        lng = loc.longitude;
      }
    } catch (e) {
      // Ignore if location is unavailable; the backend will fall back or error.
    }

    final typeFilter = serviceTypes.length == 1
        ? _serviceToFilter(serviceTypes.first)
        : null;

    // Call listJobs once with the new parameters
    final jobs = await _service.listJobs(
      typeFilter: typeFilter,
      driverLat: lat,
      driverLng: lng,
      acceptsRides: acceptsRides,
      acceptsParcels: acceptsParcels,
      limit: 10,
    );

    // Newest-first (backend may not sort consistently).
    jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    for (final job in jobs) {
      final s = job.status.toUpperCase();
      if (s != 'PENDING' && s != 'AVAILABLE' && s != 'SEARCHING') continue;
      if (job.id.isEmpty || seenIds.contains(job.id)) continue;
      seenIds.add(job.id);

      // Use inferred service type so ride jobs map to the expected UI bucket.
      allOrders.add(_jobToOrderRequest(job, _inferServiceTypeFromJob(job)));

      if (allOrders.length >= 6) break; // Arbitrary UI cap
    }

    state = NewOrdersState(orders: allOrders, selectedIndex: 0);
  }

  // Keep backward compatibility.
  void simulateNewOrders({String serviceType = 'parcel'}) {
    fetchOrdersForServices([serviceType]);
  }

  void simulateMultipleServiceOrders(List<String> serviceTypes) {
    fetchOrdersForServices(serviceTypes);
  }

  void simulateNewOrder({String serviceType = 'parcel'}) =>
      simulateNewOrders(serviceType: serviceType);

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

  /// Maps service IDs to backend type_filter values.
  /// Currently only parcel and car_booking (ride) are active.
  String _serviceToFilter(String serviceType) {
    switch (serviceType) {
      case 'car_booking':
        return 'ride';
      case 'food_delivery':
        return 'food';
      case 'heavy_delivery':
        return 'heavy';
      case 'parcel':
      default:
        return serviceType;
    }
  }

  OrderRequest _jobToOrderRequest(DispatchJob job, String serviceType) {
    String? storeName;
    String? cuisine;
    String? items;

    switch (serviceType) {
      case 'parcel':
        storeName = 'Pickup from ${job.customerName}';
        items = job.requirements?['items']?.toString() ?? 'Parcel delivery';
        cuisine = 'Courier Delivery';
        break;
      case 'car_booking':
        storeName = 'Pickup Point';
        items = 'Ride to ${job.dropAddress.split(',').first}';
        cuisine = 'Intercity Ride';
        break;
      // case 'food_delivery':
      // case 'food':
      //   storeName = job.customerName.isNotEmpty
      //       ? job.customerName
      //       : job.pickupAddress.split(',').first;
      //   items = job.requirements?['items']?.toString() ?? 'Food order';
      //   cuisine = 'Restaurant';
      //   break;
    }

    return dispatchJobToOrderRequest(
      job,
      storeNameOverride: storeName,
      cuisineOverride: cuisine,
      itemsOverride: items,
    );
  }
}
