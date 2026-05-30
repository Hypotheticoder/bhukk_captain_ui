// ── Enriched Order Request Model ──
class OrderRequest {
  final String orderId;
  final String externalOrderId; // Bridge ID for parcel backend tracking
  final String storeName;
  final String cuisineType;
  final double restaurantRating;
  final String pickupAddress;
  final String dropAddress;
  final String customerName;
  final String distance;
  final double earnings;
  final double baseFare;
  final double distanceFare;
  final double platformFee;
  final double customerOrderAmount;
  final String items;
  final int itemCount;
  final int estimatedTime;
  final String paymentMethod;
  final String paymentStatus;
  final String serviceType;

  /// Backend-provided route polyline (if available).
  /// Typically an encoded polyline string.
  final String? encodedPolyline;

  // ── Real coordinates from backend ──
  final double pickupLat;
  final double pickupLng;
  final double dropLat;
  final double dropLng;

  // ── OTP from backend ──
  final String? pickupOtp;
  final String? dropOtp;

  // ── Contact Info ──
  final String pickupPhone;
  final String dropPhone;
  final String pickupName;
  final String dropName;

  // ── Backend Status ──
  final String status;

  const OrderRequest({
    required this.orderId,
    this.externalOrderId = '',
    required this.storeName,
    required this.cuisineType,
    required this.restaurantRating,
    required this.pickupAddress,
    required this.dropAddress,
    required this.customerName,
    required this.distance,
    required this.earnings,
    this.baseFare = 0.0,
    this.distanceFare = 0.0,
    this.platformFee = 0.0,
    this.customerOrderAmount = 0.0,
    required this.items,
    required this.itemCount,
    required this.estimatedTime,
    required this.paymentMethod,
    this.paymentStatus = 'paid',
    this.serviceType = 'food',
    this.encodedPolyline,
    this.pickupLat = 0.0,
    this.pickupLng = 0.0,
    this.dropLat = 0.0,
    this.dropLng = 0.0,
    this.pickupOtp,
    this.dropOtp,
    this.pickupPhone = '',
    this.dropPhone = '',
    this.pickupName = '',
    this.dropName = '',
    this.status = 'assigned',
  });
}

// ── State ──
class NewOrdersState {
  final List<OrderRequest> orders;
  final int selectedIndex;

  const NewOrdersState({this.orders = const [], this.selectedIndex = 0});

  bool get hasOrders => orders.isNotEmpty;
  OrderRequest? get selectedOrder =>
      orders.isNotEmpty && selectedIndex < orders.length
      ? orders[selectedIndex]
      : null;

  NewOrdersState copyWith({List<OrderRequest>? orders, int? selectedIndex}) {
    return NewOrdersState(
      orders: orders ?? this.orders,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}
