import 'package:bhukkdelivery/models/dispatch_job.dart';
import 'package:bhukkdelivery/models/order_request.dart';
import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Shared conversion: DispatchJob → OrderRequest with real coordinates.
OrderRequest dispatchJobToOrderRequest(
  DispatchJob job, {
  String? storeNameOverride,
  String? cuisineOverride,
  String? itemsOverride,
}) {
  return OrderRequest(
    orderId: job.id,
    externalOrderId: job.externalOrderId,
    storeName: storeNameOverride ?? job.customerName,
    cuisineType: cuisineOverride ?? job.orderType,
    restaurantRating: (job.requirements?['rating'] as num?)?.toDouble() ?? 4.5,
    pickupAddress: job.pickupAddress,
    dropAddress: job.dropAddress,
    customerName: job.customerName,
    distance: '${job.distanceKm.toStringAsFixed(1)} km',
    earnings: job.deliveryFee,
    baseFare: job.baseFare,
    distanceFare: job.distanceFare,
    platformFee: job.platformFee,
    customerOrderAmount: job.customerOrderAmount,
    items:
        itemsOverride ??
        job.requirements?['items']?.toString() ??
        'Dispatch job',
    itemCount: job.itemCount,
    estimatedTime: job.estimatedTimeMins,
    paymentMethod: job.paymentMethod,
    paymentStatus: job.paymentStatus,
    serviceType: job.orderType,
    encodedPolyline: job.encodedPolyline,
    // Real coordinates from backend
    pickupLat: job.pickupLat,
    pickupLng: job.pickupLng,
    dropLat: job.dropLat,
    dropLng: job.dropLng,
    pickupOtp: job.pickupOtp,
    dropOtp: job.dropOtp,
    pickupPhone: job.pickupPhone,
    dropPhone: job.dropPhone,
    pickupName: job.pickupName,
    dropName: job.dropName,
    status: job.status,
  );
}

/// Shared conversion: OrderRequest → ActiveDelivery with real coordinates.
ActiveDelivery orderRequestToActiveDelivery(
  OrderRequest order, {
  String? serviceTypeOverride,
}) {
  // Use real coordinates from backend, fall back to defaults if zero.
  final pickupLat = order.pickupLat != 0 ? order.pickupLat : 22.4853;
  final pickupLng = order.pickupLng != 0 ? order.pickupLng : 88.3693;
  final dropLat = order.dropLat != 0 ? order.dropLat : 22.5726;
  final dropLng = order.dropLng != 0 ? order.dropLng : 88.3639;

  DeliveryStatus parseStatus(String? st) {
    if (st == null) return DeliveryStatus.headingToStore;
    final s = st.toLowerCase();
    if (s == 'arrived') return DeliveryStatus.arrivedAtStore;
    if (s == 'picked_up') return DeliveryStatus.pickedUp;
    if (s == 'en_route') return DeliveryStatus.enRoute;
    if (s == 'arriving') return DeliveryStatus.arriving;
    if (s == 'delivered') return DeliveryStatus.delivered;
    return DeliveryStatus.headingToStore;
  }

  return ActiveDelivery(
    orderId: order.orderId,
    externalOrderId: order.externalOrderId,
    storeName: order.storeName,
    customerName: order.customerName,
    items: order.items,
    earnings: order.earnings,
    distance: order.distance,
    pickupLocation: LatLng(pickupLat, pickupLng),
    dropoffLocation: LatLng(dropLat, dropLng),
    status: parseStatus(order.status),
    storeAddress: order.pickupAddress,
    customerAddress: order.dropAddress,
    pickupOtp: order.pickupOtp ?? '',
    deliveryOtp: order.dropOtp ?? '',
    encodedPolyline: order.encodedPolyline,
    serviceType: serviceTypeOverride ?? order.serviceType,
    orderAmount: order.customerOrderAmount > 0
        ? order.customerOrderAmount
        : order.earnings,
    paymentMethod: order.paymentMethod,
    paymentStatus: order.paymentStatus,
    pickupPhone: order.pickupPhone,
    dropPhone: order.dropPhone,
    pickupName: order.pickupName,
    dropName: order.dropName,
  );
}
