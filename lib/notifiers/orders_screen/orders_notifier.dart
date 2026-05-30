import 'package:bhukkdelivery/providers/profile/profile_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:bhukkdelivery/services/api/orders_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Order Status ──
enum OrderStatus { completed, cancelled, inProgress }

// ── Order Model ──
class OrderItem {
  final String id;
  final String storeName;
  final String customerName;
  final String pickupAddress;
  final String dropAddress;
  final double amount;
  final OrderStatus status;
  final double distanceKm;
  final int durationMin;
  final DateTime dateTime;
  final String paymentMethod;
  final int itemCount;
  final String serviceType;
  
  // Breakdown fields
  final double customerOrderAmount;
  final double baseFare;
  final double distanceFare;
  final double platformFee;

  const OrderItem({
    required this.id,
    required this.storeName,
    required this.customerName,
    required this.pickupAddress,
    required this.dropAddress,
    required this.amount,
    required this.status,
    required this.distanceKm,
    required this.durationMin,
    required this.dateTime,
    required this.paymentMethod,
    required this.itemCount,
    this.serviceType = 'food',
    this.customerOrderAmount = 0.0,
    this.baseFare = 0.0,
    this.distanceFare = 0.0,
    this.platformFee = 0.0,
  });
}

// ── Service type metadata ──
class ServiceMeta {
  final String label;
  final IconData icon;
  final Color color;

  const ServiceMeta(this.label, this.icon, this.color);
}

const Map<String, ServiceMeta> serviceMetaMap = {
  'ride': ServiceMeta('Ride', Icons.directions_car_rounded, AppColors.carBooking),
  'parcel': ServiceMeta('Parcel', Icons.inventory_2_rounded, AppColors.parcel),
  'medicine': ServiceMeta('Medicine', Icons.local_pharmacy_rounded, AppColors.success),
};

// ── Filter Labels ──
const List<String> orderStatusLabels = [
  'All',
  'Completed',
  'Cancelled',
];

const List<String> serviceFilterLabels = [
  'All',
  'Ride',
  'Parcel',
  'Medicine',
];

const Map<String, String> _serviceFilterKeyMap = {
  'All': 'all',
  'Ride': 'ride',
  'Parcel': 'parcel',
  'Medicine': 'medicine',
};

// ── State ──
class OrdersState {
  final List<OrderItem> allOrders;
  final List<OrderItem> filteredOrders;
  final int selectedFilterIndex;
  final int selectedServiceIndex;
  final String searchQuery;
  final bool isLoading;
  final List<String> availableServiceFilters;

  const OrdersState({
    this.allOrders = const [],
    this.filteredOrders = const [],
    this.selectedFilterIndex = 0,
    this.selectedServiceIndex = 0,
    this.searchQuery = '',
    this.isLoading = true,
    this.availableServiceFilters = const ['All', 'Ride', 'Parcel', 'Medicine'],
  });

  OrdersState copyWith({
    List<OrderItem>? allOrders,
    List<OrderItem>? filteredOrders,
    int? selectedFilterIndex,
    int? selectedServiceIndex,
    String? searchQuery,
    bool? isLoading,
    List<String>? availableServiceFilters,
  }) {
    return OrdersState(
      allOrders: allOrders ?? this.allOrders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      selectedFilterIndex: selectedFilterIndex ?? this.selectedFilterIndex,
      selectedServiceIndex: selectedServiceIndex ?? this.selectedServiceIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      availableServiceFilters: availableServiceFilters ?? this.availableServiceFilters,
    );
  }

  // Computed stats (on filtered list context)
  List<OrderItem> get _statsSource {
    // Stats are computed on the service-filtered set (before status filter)
    final svcKey =
        _serviceFilterKeyMap[serviceFilterLabels[selectedServiceIndex]] ??
        'all';
    if (svcKey == 'all') return allOrders;
    return allOrders.where((o) => o.serviceType == svcKey).toList();
  }

  int get totalOrders => _statsSource.length;
  int get completedCount =>
      _statsSource.where((o) => o.status == OrderStatus.completed).length;
  double get completionRate =>
      totalOrders > 0 ? (completedCount / totalOrders) : 0;

  double get overallCompletionRate {
    if (allOrders.isEmpty) return 0;
    final completed = allOrders.where((o) => o.status == OrderStatus.completed).length;
    return completed / allOrders.length;
  }

  double get avgEarnings => completedCount > 0
      ? _statsSource
                .where((o) => o.status == OrderStatus.completed)
                .fold<double>(0, (sum, o) => sum + o.amount) /
            completedCount
      : 0;
}

// ── Notifier ──
class OrdersNotifier extends Notifier<OrdersState> {
  @override
  OrdersState build() {
    final vehicleType = ref.watch(profileProvider.select((p) => p?.vehicleType ?? 'bike'));
    
    final filters = ['All'];
    final isCar = vehicleType.contains('car') ||
        vehicleType.contains('cab') ||
        vehicleType.contains('taxi');
    final isTruck = vehicleType.contains('truck') ||
        vehicleType.contains('van') ||
        vehicleType.contains('lorry') ||
        vehicleType.contains('mini truck') ||
        vehicleType.contains('wheeler') ||
        vehicleType.contains('3_wheeler');

    if (isCar) {
      filters.add('Ride');
    } else if (isTruck) {
      filters.addAll(['Parcel', 'Medicine']);
    } else {
      filters.addAll(['Ride', 'Parcel', 'Medicine']);
    }

    // Initial fetch from backend
    Future.microtask(() => _fetchFromBackend());
    return OrdersState(allOrders: [], filteredOrders: [], isLoading: true, availableServiceFilters: filters);
  }

  Future<void> _fetchFromBackend() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final currentFilter = state.availableServiceFilters[state.selectedServiceIndex];
      final svcKey = _serviceFilterKeyMap[currentFilter] ?? 'all';
      
      final rawData = await OrdersService.fetchOrderHistory(serviceType: svcKey);
      
      final List<OrderItem> parsedOrders = rawData.map((json) => _mapJsonToOrderItem(Map<String, dynamic>.from(json))).toList();

      state = state.copyWith(allOrders: parsedOrders, isLoading: false);
      _applyFilters();
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint('[OrdersNotifier] Error fetching history: $e');
    }
  }

  void selectFilter(int index) {
    state = state.copyWith(selectedFilterIndex: index);
    _applyFilters();
  }

  void selectServiceFilter(int index) {
    if (state.selectedServiceIndex == index) return;
    state = state.copyWith(selectedServiceIndex: index);
    _fetchFromBackend(); // Requires new data from server
  }

  void searchOrders(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  /// Merge live WebSocket jobs into the order list.
  void addLiveJobs(List<OrderItem> liveJobs) {
    final existing = List<OrderItem>.from(state.allOrders);
    final existingIds = existing.map((o) => o.id).toSet();

    for (final job in liveJobs) {
      if (!existingIds.contains(job.id)) {
        existing.insert(0, job);
        existingIds.add(job.id);
      } else {
        final idx = existing.indexWhere((o) => o.id == job.id);
        if (idx != -1) existing[idx] = job;
      }
    }

    state = state.copyWith(allOrders: existing);
    _applyFilters();
  }

  void _applyFilters() {
    List<OrderItem> filtered = state.allOrders;

    // Service filter (Local fallback, though backend handles it)
    final currentFilter = state.availableServiceFilters[state.selectedServiceIndex];
    final svcKey = _serviceFilterKeyMap[currentFilter] ?? 'all';
    
    if (svcKey != 'all') {
      filtered = filtered.where((o) => o.serviceType == svcKey).toList();
    }

    // Status filter
    final filterIndex = state.selectedFilterIndex;
    if (filterIndex == 1) {
      filtered = filtered
          .where((o) => o.status == OrderStatus.completed)
          .toList();
    } else if (filterIndex == 2) {
      filtered = filtered
          .where((o) => o.status == OrderStatus.cancelled)
          .toList();
    } else if (filterIndex == 3) {
      filtered = filtered
          .where((o) => o.status == OrderStatus.inProgress)
          .toList();
    }

    // Search filter
    final query = state.searchQuery.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered
          .where(
            (o) =>
                o.storeName.toLowerCase().contains(query) ||
                o.id.toLowerCase().contains(query) ||
                o.customerName.toLowerCase().contains(query),
          )
          .toList();
    }

    state = state.copyWith(filteredOrders: filtered);
  }

  OrderItem _mapJsonToOrderItem(Map<String, dynamic> json) {
    // Determine status
    OrderStatus status = OrderStatus.completed;
    final rawStatus = (json['status'] ?? '').toString().toLowerCase();
    if (rawStatus == 'cancelled') {
      status = OrderStatus.cancelled;
    } else if (rawStatus == 'in_progress' || rawStatus == 'accepted' || rawStatus == 'picked_up') {
      status = OrderStatus.inProgress;
    }

    // Normalize order type for serviceMetaMap lookup
    final rawOrderType = (json['order_type'] ?? json['service_type'] ?? 'parcel').toString().toLowerCase();
    String normalizedType;
    if (rawOrderType.contains('ride') || rawOrderType == 'car' || rawOrderType == 'car_booking' || rawOrderType == 'cab') {
      normalizedType = 'ride';
    } else if (rawOrderType.contains('medicine') || rawOrderType.contains('pharmacy')) {
      normalizedType = 'medicine';
    } else {
      normalizedType = 'parcel';
    }

    // Build a readable store/route name
    final pickupAddr = json['pickup_address'] ?? '';
    final dropAddr = json['drop_address'] ?? '';
    final displayName = normalizedType == 'ride'
        ? 'Ride to ${_truncateAddress(dropAddr)}'
        : normalizedType == 'medicine'
            ? 'Medicine to ${_truncateAddress(dropAddr)}'
            : 'Parcel to ${_truncateAddress(dropAddr)}';

    // Use driver_payout if available, else total_fare
    final amount = _safeDouble(json['driver_payout']) > 0
        ? _safeDouble(json['driver_payout'])
        : _safeDouble(json['total_fare']);

    // Use pickup contact as customer name, or drop contact
    final customerName = json['pickup_contact_name'] 
        ?? json['drop_contact_name'] 
        ?? 'Customer';

    final orderId = json['id']?.toString() ?? 'N/A';
    
    final reqs = json['requirements'] is Map ? json['requirements'] as Map<String, dynamic> : null;
    final meta = json['metadata'] is Map ? json['metadata'] as Map<String, dynamic> : null;

    final customerOrderAmount = _safeDouble(
        json['customer_order_amount'] ?? 
        json['total_bill'] ?? 
        json['grand_total'] ?? 
        json['bill_amount'] ??
        json['total_amount'] ??
        json['total_fare'] ??
        json['amount'] ??
        reqs?['customer_order_amount'] ??
        reqs?['total_bill'] ??
        reqs?['grand_total'] ??
        meta?['total_bill']
    );
    
    final baseFare = _safeDouble(
      json['base_fare'] ?? 
      json['min_fare'] ?? 
      json['base_earnings'] ?? 
      json['base_pay'] ??
      reqs?['base_fare'] ?? 
      reqs?['min_fare'] ??
      reqs?['base_earnings']
    );
    
    final distanceFare = _safeDouble(
      json['distance_charge'] ??
      json['distance_fare'] ?? 
      json['km_fare'] ?? 
      json['km_charge'] ??
      json['distance_earnings'] ?? 
      json['distance_pay'] ??
      reqs?['distance_charge'] ??
      reqs?['distance_fare'] ?? 
      reqs?['km_fare'] ??
      reqs?['distance_earnings']
    );
    
    final platformFee = _safeDouble(
      json['platform_commission'] ??
      json['platform_commission_amount'] ??
      json['platform_commission_fee'] ??
      json['platform_fee'] ?? 
      json['commission'] ?? 
      json['platform_charge'] ?? 
      reqs?['platform_commission'] ??
      reqs?['platform_commission_amount'] ??
      reqs?['platform_fee'] ?? 
      reqs?['commission']
    );

    if (customerOrderAmount == 0 || baseFare == 0) {
      _debugOrderJson(json, orderId);
    }

    return OrderItem(
      id: orderId,
      storeName: displayName,
      customerName: customerName,
      pickupAddress: pickupAddr,
      dropAddress: dropAddr,
      amount: amount,
      serviceType: normalizedType,
      status: status,
      distanceKm: _safeDouble(json['distance_km']),
      paymentMethod: (json['payment_method'] ?? 'online').toString().toUpperCase(),
      itemCount: int.tryParse(json['item_count']?.toString() ?? '') ?? 1,
      durationMin: int.tryParse(json['estimated_time_mins']?.toString() ?? '') ?? 0,
      dateTime: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
      
      // Breakdown fields
      customerOrderAmount: customerOrderAmount,
      baseFare: baseFare,
      distanceFare: distanceFare,
      platformFee: platformFee,
    );
  }

  void _debugOrderJson(Map<String, dynamic> json, String orderId) {
    debugPrint('[OrdersNotifier] Order ID: $orderId, Full JSON: $json');
  }

  double _safeDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  String _truncateAddress(String addr) {
    if (addr.isEmpty) return 'Unknown';
    // Take first meaningful part before comma
    final parts = addr.split(',');
    final first = parts.first.trim();
    return first.length > 30 ? '${first.substring(0, 30)}...' : first;
  }
}
