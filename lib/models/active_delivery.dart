import 'package:google_maps_flutter/google_maps_flutter.dart';

enum DeliveryStatus {
  headingToStore,
  arrivedAtStore,
  pickedUp,
  enRoute,
  arriving,
  delivered,
}

enum OtpType { pickup, delivery }

class ActiveDelivery {
  final String orderId;
  final String externalOrderId; // Bridge ID for parcel backend WebSocket room
  final String storeName;
  final String customerName;
  final String items;
  final double earnings;
  final String distance;
  final LatLng pickupLocation;
  final LatLng dropoffLocation;
  final DeliveryStatus status;
  final String storeAddress;
  final String customerAddress;
  final String pickupOtp;
  final String deliveryOtp;
  final String serviceType;
  final double orderAmount;
  final String paymentMethod;
  final String paymentStatus;

  /// Contact Info
  final String pickupPhone;
  final String dropPhone;
  final String pickupName;
  final String dropName;

  /// Backend-provided route polyline (if any).
  final String? encodedPolyline;

  const ActiveDelivery({
    required this.orderId,
    this.externalOrderId = '',
    required this.storeName,
    required this.customerName,
    required this.items,
    required this.earnings,
    required this.distance,
    required this.pickupLocation,
    required this.dropoffLocation,
    this.status = DeliveryStatus.headingToStore,
    this.storeAddress = '',
    this.customerAddress = '',
    this.pickupOtp = '',
    this.deliveryOtp = '',
    this.serviceType = 'general',
    this.orderAmount = 0.0,
    this.paymentMethod = 'UPI',
    this.paymentStatus = 'paid',
    this.encodedPolyline,
    this.pickupPhone = '',
    this.dropPhone = '',
    this.pickupName = '',
    this.dropName = '',
  });

  ActiveDelivery copyWith({
    DeliveryStatus? status,
    String? storeAddress,
    String? customerAddress,
    String? pickupOtp,
    String? deliveryOtp,
    String? serviceType,
    double? orderAmount,
    String? paymentMethod,
    String? paymentStatus,
    String? encodedPolyline,
    String? pickupPhone,
    String? dropPhone,
    String? pickupName,
    String? dropName,
  }) {
    return ActiveDelivery(
      orderId: orderId,
      externalOrderId: externalOrderId,
      storeName: storeName,
      customerName: customerName,
      items: items,
      earnings: earnings,
      distance: distance,
      pickupLocation: pickupLocation,
      dropoffLocation: dropoffLocation,
      status: status ?? this.status,
      storeAddress: storeAddress ?? this.storeAddress,
      customerAddress: customerAddress ?? this.customerAddress,
      pickupOtp: pickupOtp ?? this.pickupOtp,
      deliveryOtp: deliveryOtp ?? this.deliveryOtp,
      serviceType: serviceType ?? this.serviceType,
      orderAmount: orderAmount ?? this.orderAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      encodedPolyline: encodedPolyline ?? this.encodedPolyline,
      pickupPhone: pickupPhone ?? this.pickupPhone,
      dropPhone: dropPhone ?? this.dropPhone,
      pickupName: pickupName ?? this.pickupName,
      dropName: dropName ?? this.dropName,
    );
  }

  String get _serviceKey {
    final raw = serviceType.trim().toLowerCase();
    if (raw == 'car' || raw == 'car_booking' || raw == 'cab') return 'ride';
    if (raw.contains('ride')) return 'ride';
    if (raw.contains('parcel')) return 'parcel';
    return raw;
  }

  bool get isRide => _serviceKey == 'ride';
  bool get isParcel => _serviceKey == 'parcel';

  /// Whether the customer chose Cash on Delivery
  bool get isCashOnDelivery {
    final pm = paymentMethod.trim().toLowerCase();
    return pm == 'cod' ||
        pm == 'cash' ||
        pm == 'cash_on_delivery' ||
        pm == 'cashondelivery';
  }

  /// Whether payment has been collected
  bool get isPaymentPending {
    return paymentStatus.toLowerCase() == 'unpaid' || paymentStatus.toLowerCase() == 'pending';
  }

  /// Whether the driver is in the store-pickup phase
  bool get isPickupPhase =>
      status == DeliveryStatus.headingToStore ||
      status == DeliveryStatus.arrivedAtStore;

  /// Whether the current status requires OTP verification to advance
  bool get requiresOtp {
    // Business rules:
    // - Ride: OTP at pickup + drop
    // - Parcel: OTP at arrived + delivered
    if (isRide || isParcel) {
      return status == DeliveryStatus.arrivedAtStore ||
          status == DeliveryStatus.arriving;
    }

    // Other services: only require OTP if backend provided one.
    if (status == DeliveryStatus.arrivedAtStore) return pickupOtp.isNotEmpty;
    if (status == DeliveryStatus.arriving) return deliveryOtp.isNotEmpty;
    return false;
  }

  /// The relevant OTP type for the current status
  OtpType? get currentOtpType {
    if (status == DeliveryStatus.arrivedAtStore && requiresOtp) {
      return OtpType.pickup;
    }
    if (status == DeliveryStatus.arriving && requiresOtp) {
      return OtpType.delivery;
    }
    return null;
  }

  /// The expected OTP for the current phase
  String get currentExpectedOtp {
    if (status == DeliveryStatus.arrivedAtStore) return pickupOtp;
    if (status == DeliveryStatus.arriving) return deliveryOtp;
    return '';
  }

  int get stepIndex {
    switch (status) {
      case DeliveryStatus.headingToStore:
        return 0;
      case DeliveryStatus.arrivedAtStore:
        return 1;
      case DeliveryStatus.pickedUp:
        return 2;
      case DeliveryStatus.enRoute:
        return 3;
      case DeliveryStatus.arriving:
        return 4;
      case DeliveryStatus.delivered:
        return 5;
    }
  }

  String get statusLabel {
    if (isRide) {
      switch (status) {
        case DeliveryStatus.headingToStore:
          return 'Heading to Pickup';
        case DeliveryStatus.arrivedAtStore:
          return 'Arrived at Pickup';
        case DeliveryStatus.pickedUp:
          return 'Trip Started';
        case DeliveryStatus.enRoute:
          return 'En Route';
        case DeliveryStatus.arriving:
          return 'Arriving';
        case DeliveryStatus.delivered:
          return 'Trip Completed';
      }
    }
    switch (status) {
      case DeliveryStatus.headingToStore:
        return 'Heading to Store';
      case DeliveryStatus.arrivedAtStore:
        return 'Arrived at Store';
      case DeliveryStatus.pickedUp:
        return 'Picked Up';
      case DeliveryStatus.enRoute:
        return 'En Route';
      case DeliveryStatus.arriving:
        return 'Arriving';
      case DeliveryStatus.delivered:
        return 'Delivered';
    }
  }

  String get actionButtonLabel {
    if (isRide) {
      switch (status) {
        case DeliveryStatus.headingToStore:
          return 'Arrived at Pickup';
        case DeliveryStatus.arrivedAtStore:
          return requiresOtp ? 'Enter Pickup OTP' : 'Start Trip';
        case DeliveryStatus.pickedUp:
          return 'Start Navigation';
        case DeliveryStatus.enRoute:
          return 'Mark as Arriving';
        case DeliveryStatus.arriving:
          if (isCashOnDelivery && isPaymentPending) return 'Collect Payment';
          return requiresOtp ? 'Enter Drop OTP' : 'Complete Trip ✓';
        case DeliveryStatus.delivered:
          return 'Complete Trip ✓';
      }
    }

    if (isParcel) {
      switch (status) {
        case DeliveryStatus.headingToStore:
          return 'Arrived at Pickup';
        case DeliveryStatus.arrivedAtStore:
          return requiresOtp ? 'Enter Arrived OTP' : 'Confirm Pickup';
        case DeliveryStatus.pickedUp:
          return 'Start Delivery';
        case DeliveryStatus.enRoute:
          return 'Mark as Arriving';
        case DeliveryStatus.arriving:
          if (isCashOnDelivery && isPaymentPending) return 'Collect Payment';
          return requiresOtp ? 'Enter Delivered OTP' : 'Complete Delivery ✓';
        case DeliveryStatus.delivered:
          return 'Complete Delivery ✓';
      }
    }
    switch (status) {
      case DeliveryStatus.headingToStore:
        return 'Arrived at Store';
      case DeliveryStatus.arrivedAtStore:
        return requiresOtp ? 'Enter Pickup OTP' : 'Confirm Pickup';
      case DeliveryStatus.pickedUp:
        return 'Start Delivery';
      case DeliveryStatus.enRoute:
        return 'Mark as Arriving';
      case DeliveryStatus.arriving:
        if (isCashOnDelivery && isPaymentPending) return 'Collect Payment';
        return requiresOtp ? 'Enter Delivery OTP' : 'Complete Delivery ✓';
      case DeliveryStatus.delivered:
        return 'Complete Delivery ✓';
    }
  }

  /// Generate a random 4-digit OTP
  static String generateOtp() {
    return '1234'; // Any number for now
  }
}
