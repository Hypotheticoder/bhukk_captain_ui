import 'package:flutter/foundation.dart';
import 'package:bhukkdelivery/notifiers/orders_screen/orders_notifier.dart';

/// Model mapping the backend DispatchJob (DispatchJobRead schema).
class DispatchJob {
  final String id;
  final String? driverId;
  final String sourceApp; // e.g. 'parcel', 'ride'
  final String externalOrderId;
  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;
  final String dropAddress;
  final double dropLat;
  final double dropLng;
  final String? encodedPolyline;
  final double deliveryFee;
  final double baseFare;
  final double distanceFare;
  final double platformFee;
  final double customerOrderAmount; // The total bill from customer side
  final String vehicleType; // e.g. 'bike', 'parcel_bike', 'car'
  final String status; // 'PENDING', 'ACCEPTED', 'COMPLETED', etc.
  final String? pickupOtp;
  final String? dropOtp;
  final Map<String, dynamic>? requirements;
  final DateTime createdAt;
  final String paymentMethod;
  final String paymentStatus;
  final int itemCount;
  final int estimatedTimeMins;
  final String pickupPhone;
  final String dropPhone;
  final String pickupName;
  final String dropName;

  // Private: stored from top-level JSON for CustomerOrderRead compat
  final double _topLevelDistanceKm;
  final String _topLevelCustomerName;

  const DispatchJob({
    required this.id,
    this.driverId,
    required this.sourceApp,
    required this.externalOrderId,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropAddress,
    required this.dropLat,
    required this.dropLng,
    this.encodedPolyline,
    required this.deliveryFee,
    this.baseFare = 0.0,
    this.distanceFare = 0.0,
    this.platformFee = 0.0,
    this.customerOrderAmount = 0.0,
    this.vehicleType = '',
    required this.status,
    this.pickupOtp,
    this.dropOtp,
    this.requirements,
    required this.createdAt,
    this.paymentMethod = 'UPI',
    this.paymentStatus = 'paid',
    this.itemCount = 1,
    this.estimatedTimeMins = 15,
    this.pickupPhone = '',
    this.dropPhone = '',
    this.pickupName = '',
    this.dropName = '',
    double topLevelDistanceKm = 0.0,
    String topLevelCustomerName = '',
  }) : _topLevelDistanceKm = topLevelDistanceKm,
       _topLevelCustomerName = topLevelCustomerName;

  static double _parseDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int _parseInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Parse from backend JSON (DispatchJobRead).
  factory DispatchJob.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';

    final externalOrderId =
        json['external_order_id']?.toString() ??
        json['externalOrderId']?.toString() ??
        json['bridge_id']?.toString() ??
        id;

    final sourceApp =
        json['source_app']?.toString() ??
        json['service_type']?.toString() ??
        json['order_type']?.toString() ??
        'parcel';

    // Extract requirements early for fallback checking
    final reqs = json['requirements'] is Map
        ? Map<String, dynamic>.from(json['requirements'])
        : null;

    final deliveryFee = _parseDouble(json['delivery_fee']) > 0
        ? _parseDouble(json['delivery_fee'])
        : _parseDouble(json['fare']) > 0
        ? _parseDouble(json['fare'])
        : _parseDouble(json['amount']) > 0
        ? _parseDouble(json['amount'])
        : _parseDouble(json['driver_payout']) > 0
        ? _parseDouble(json['driver_payout'])
        : _parseDouble(reqs?['delivery_fee']) > 0
        ? _parseDouble(reqs?['delivery_fee'])
        : _parseDouble(reqs?['fare']) > 0
        ? _parseDouble(reqs?['fare'])
        : _parseDouble(reqs?['driver_payout']);

    final baseFare = _parseDouble(json['base_fare']) > 0
        ? _parseDouble(json['base_fare'])
        : _parseDouble(reqs?['base_fare']);

    final distanceFare = _parseDouble(json['distance_charge']) > 0
        ? _parseDouble(json['distance_charge'])
        : _parseDouble(json['distance_fare']) > 0
        ? _parseDouble(json['distance_fare'])
        : _parseDouble(reqs?['distance_fare']);

    final platformFee =
        _parseNullableDouble(json['platform_commission']) ??
        _parseNullableDouble(json['platform_commission_amount']) ??
        _parseNullableDouble(json['platform_commission_fee']) ??
        _parseNullableDouble(json['platform_fee']) ??
        _parseNullableDouble(json['platform_charge']) ??
        _parseNullableDouble(reqs?['platform_commission']) ??
        _parseNullableDouble(reqs?['platform_commission_amount']) ??
        _parseNullableDouble(reqs?['platform_commission_fee']) ??
        _parseNullableDouble(reqs?['platform_fee']) ??
        _parseNullableDouble(reqs?['platform_charge']) ??
        0.0;

    final customerOrderAmount = _parseDouble(json['total_fare']) > 0
        ? _parseDouble(json['total_fare'])
        : _parseDouble(json['customer_order_amount']) > 0
        ? _parseDouble(json['customer_order_amount'])
        : _parseDouble(json['order_amount']) > 0
        ? _parseDouble(json['order_amount'])
        : _parseDouble(json['total_bill']) > 0
        ? _parseDouble(json['total_bill'])
        : _parseDouble(json['grand_total']) > 0
        ? _parseDouble(json['grand_total'])
        : _parseDouble(json['bill_amount']) > 0
        ? _parseDouble(json['bill_amount'])
        : _parseDouble(json['total_price']) > 0
        ? _parseDouble(json['total_price'])
        : _parseDouble(json['total_amount']) > 0
        ? _parseDouble(json['total_amount'])
        : _parseDouble(json['amount']) > 0
        ? _parseDouble(json['amount'])
        : _parseDouble(reqs?['customer_order_amount']) > 0
        ? _parseDouble(reqs?['customer_order_amount'])
        : _parseDouble(reqs?['order_amount']) > 0
        ? _parseDouble(reqs?['order_amount'])
        : _parseDouble(reqs?['total_bill']) > 0
        ? _parseDouble(reqs?['total_bill'])
        : _parseDouble(reqs?['grand_total']) > 0
        ? _parseDouble(reqs?['grand_total'])
        : _parseDouble(reqs?['amount']);

    if (customerOrderAmount == 0) {
      debugPrint('[DispatchJob] WARNING: customerOrderAmount is 0. JSON: $json');
    }

    final paymentMethod =
        json['payment_method']?.toString() ??
        reqs?['payment_method']?.toString() ??
        'UPI';

    final paymentStatus =
        json['payment_status']?.toString() ??
        reqs?['payment_status']?.toString() ??
        'paid';

    final itemCount = _parseInt(json['item_count']) > 0
        ? _parseInt(json['item_count'])
        : _parseInt(reqs?['item_count']) > 0
        ? _parseInt(reqs?['item_count'])
        : 1;

    final estimatedTime = _parseInt(json['estimated_time_mins']) > 0
        ? _parseInt(json['estimated_time_mins'])
        : _parseInt(json['estimated_time_min']) > 0
        ? _parseInt(json['estimated_time_min'])
        : _parseInt(reqs?['estimated_time_mins']) > 0
        ? _parseInt(reqs?['estimated_time_mins'])
        : _parseInt(reqs?['estimated_time_min']) > 0
        ? _parseInt(reqs?['estimated_time_min'])
        : 15;

    final pickupPhone = json['pickup_contact_phone']?.toString() ??
        json['pickup_phone']?.toString() ??
        json['sender_phone']?.toString() ??
        reqs?['pickup_contact_phone']?.toString() ??
        reqs?['pickup_phone']?.toString() ??
        reqs?['sender_phone']?.toString() ??
        reqs?['pickup_contact']?.toString() ??
        '';

    final dropPhone = json['drop_contact_phone']?.toString() ??
        json['drop_phone']?.toString() ??
        json['receiver_phone']?.toString() ??
        json['customer_phone']?.toString() ??
        reqs?['drop_contact_phone']?.toString() ??
        reqs?['drop_phone']?.toString() ??
        reqs?['receiver_phone']?.toString() ??
        reqs?['drop_contact']?.toString() ??
        '';

    final pickupName = json['pickup_contact_name']?.toString() ??
        json['sender_name']?.toString() ??
        json['store_name']?.toString() ??
        reqs?['pickup_contact_name']?.toString() ??
        reqs?['sender_name']?.toString() ??
        reqs?['store_name']?.toString() ??
        '';

    final dropName = json['drop_contact_name']?.toString() ??
        json['receiver_name']?.toString() ??
        json['customer_name']?.toString() ??
        reqs?['drop_contact_name']?.toString() ??
        reqs?['receiver_name']?.toString() ??
        reqs?['customer_name']?.toString() ??
        '';

    return DispatchJob(
      id: id,
      driverId:
          json['driver_id']?.toString() ??
          json['assigned_driver_id']?.toString(),
      sourceApp: sourceApp,
      externalOrderId: externalOrderId,
      pickupAddress: json['pickup_address']?.toString() ?? '',
      pickupLat: _parseDouble(json['pickup_lat']),
      pickupLng: _parseDouble(json['pickup_lng']),
      dropAddress: json['drop_address']?.toString() ?? '',
      dropLat: _parseDouble(json['drop_lat']),
      dropLng: _parseDouble(json['drop_lng']),
      encodedPolyline: json['encoded_polyline']?.toString(),
      deliveryFee: deliveryFee,
      baseFare: baseFare,
      distanceFare: distanceFare,
      platformFee: platformFee,
      customerOrderAmount: customerOrderAmount,
      vehicleType: json['vehicle_type']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      pickupOtp: json['pickup_otp']?.toString(),
      dropOtp: json['drop_otp']?.toString(),
      requirements: reqs,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      topLevelDistanceKm: _parseDouble(json['distance_km']),
      topLevelCustomerName: json['customer_name']?.toString() ?? '',
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      itemCount: itemCount,
      estimatedTimeMins: estimatedTime,
      pickupPhone: pickupPhone,
      dropPhone: dropPhone,
      pickupName: pickupName,
      dropName: dropName,
    );
  }

  /// Expose the original normalized type
  String get orderType => _normalizeServiceType(sourceApp);

  /// Safe distance in km.
  /// Checks top-level JSON first (CustomerOrderRead), then requirements.
  double get distanceKm {
    if (_topLevelDistanceKm > 0) return _topLevelDistanceKm;
    return (requirements?['distance_km'] as num?)?.toDouble() ?? 0.0;
  }

  /// Customer name.
  /// Checks top-level JSON first (CustomerOrderRead), then requirements.
  String get customerName {
    if (_topLevelCustomerName.isNotEmpty) return _topLevelCustomerName;
    return requirements?['customer_name']?.toString() ?? 'Customer';
  }

  /// Convert to the existing [OrderItem] model for UI display.
  OrderItem toOrderItem() {
    return OrderItem(
      id: id,
      storeName: _serviceLabel(orderType),
      customerName: customerName,
      pickupAddress: pickupAddress,
      dropAddress: dropAddress,
      amount: deliveryFee,
      status: _mapStatus(status),
      distanceKm: distanceKm,
      durationMin: estimatedTimeMins,
      dateTime: createdAt,
      paymentMethod: paymentMethod,
      itemCount: itemCount,
      serviceType: _normalizeServiceType(orderType),
    );
  }

  /// Map backend uppercase status to OrderStatus enum.
  static OrderStatus _mapStatus(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return OrderStatus.completed;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      default: // PENDING, ACCEPTED, IN_TRANSIT, etc.
        return OrderStatus.inProgress;
    }
  }

  /// Normalize service type keys to match existing UI keys.
  static String _normalizeServiceType(String type) {
    switch (type.toLowerCase()) {
      case 'parcel':
        return 'parcel';
      case 'ride':
      case 'car_booking':
      case 'cab':
      case 'car':
        return 'ride';
      case 'food_delivery':
      case 'food':
        return 'food';
      case 'ambulance':
        return 'ambulance';
      case 'heavy_delivery':
      case 'heavy':
        return 'heavy';
      case 'cosmatics':
        return 'cosmatics';
      case 'beverages':
        return 'beverages';
      default:
        return type;
    }
  }

  /// Friendly label for store name display.
  static String _serviceLabel(String type) {
    switch (type.toLowerCase()) {
      case 'parcel':
        return 'Parcel Dispatch';
      case 'ride':
      case 'car_booking':
      case 'cab':
        return 'Car Booking';
      case 'food_delivery':
      case 'food':
        return 'Food Delivery';
      case 'ambulance':
        return 'Ambulance Service';
      case 'heavy_delivery':
      case 'heavy':
        return 'Heavy Delivery';
      case 'cosmatics':
        return 'Cosmatics Delivery';
      case 'beverages':
        return 'Beverages Delivery';
      default:
        return 'Dispatch Job';
    }
  }
}
