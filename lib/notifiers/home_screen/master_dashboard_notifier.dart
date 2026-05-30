import 'package:bhukkdelivery/providers/earnings/earnings_provider.dart';
import 'package:bhukkdelivery/providers/orders/orders_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:bhukkdelivery/providers/profile/profile_provider.dart';
import 'package:bhukkdelivery/providers/home/service_status_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Summary data for a single delivery service, shown on the master dashboard.
class ServiceSummary {
  final String serviceId;
  final String name;
  final IconData icon;
  final IconData? secondaryIcon;
  final Color color;
  final String route;
  final int todayOrders;
  final double todayEarnings;
  final bool isOnline;

  const ServiceSummary({
    required this.serviceId,
    required this.name,
    required this.icon,
    this.secondaryIcon,
    required this.color,
    required this.route,
    required this.todayOrders,
    required this.todayEarnings,
    required this.isOnline,
  });

  ServiceSummary copyWith({
    String? serviceId,
    String? name,
    IconData? icon,
    IconData? secondaryIcon,
    Color? color,
    String? route,
    int? todayOrders,
    double? todayEarnings,
    bool? isOnline,
  }) {
    return ServiceSummary(
      serviceId: serviceId ?? this.serviceId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      secondaryIcon: secondaryIcon ?? this.secondaryIcon,
      color: color ?? this.color,
      route: route ?? this.route,
      todayOrders: todayOrders ?? this.todayOrders,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

/// Aggregate state for the master dashboard.
class MasterDashboardState {
  final List<ServiceSummary> services;
  final int totalOrders;
  final double totalEarnings;
  final double completionRate;

  const MasterDashboardState({
    required this.services,
    this.totalOrders = 0,
    this.totalEarnings = 0.0,
    this.completionRate = 0.0,
  });

  bool get isAnyServiceOnline => services.any((s) => s.isOnline);
}

class MasterDashboardNotifier extends Notifier<MasterDashboardState> {
  @override
  MasterDashboardState build() {
    // Watch profile for vehicle type
    final vehicleType = ref
        .watch(profileProvider.select((p) => p?.vehicleType ?? 'bike'))
        .toLowerCase();

    // Watch live earnings and orders
    final earnings = ref.watch(earningsProvider);
    final orders = ref.watch(ordersProvider);
    
    // Watch service online status persistently
    final serviceStatuses = ref.watch(serviceStatusProvider);

    final allServices = [
      ServiceSummary(
        serviceId: 'parcel',
        name: 'Parcel',
        icon: Icons.inventory_2_rounded,
        color: AppColors.parcel,
        route: '/home/parcel',
        todayOrders: 0,
        todayEarnings: earnings.parcelEarnings,
        isOnline: serviceStatuses['parcel'] ?? false,
      ),
      ServiceSummary(
        serviceId: 'car_booking',
        name: 'Ride',
        icon: Icons.directions_car_rounded,
        secondaryIcon: Icons.two_wheeler_rounded,
        color: AppColors.carBooking,
        route: '/home/car_booking',
        todayOrders: 0,
        todayEarnings: earnings.rideEarnings,
        isOnline: serviceStatuses['car_booking'] ?? false,
      ),
      ServiceSummary(
        serviceId: 'medicine',
        name: 'Medicine',
        icon: Icons.medical_services_rounded,
        color: AppColors.medicine,
        route: '/home/medicine',
        todayOrders: 0,
        todayEarnings: earnings.medicineEarnings,
        isOnline: serviceStatuses['medicine'] ?? false,
      ),
    ];

    List<ServiceSummary> filtered;
    final isCar = vehicleType.contains('car') ||
        vehicleType.contains('cab') ||
        vehicleType.contains('taxi');
    final isTruck = vehicleType.contains('truck') ||
        vehicleType.contains('van') ||
        vehicleType.contains('lorry') ||
        vehicleType.contains('mini truck') ||
        vehicleType.contains('3_wheeler') ||
        vehicleType.contains('wheeler');

    if (isCar) {
      filtered = allServices.where((s) => s.serviceId == 'car_booking').toList();
    } else if (isTruck) {
      filtered = allServices.where((s) => s.serviceId == 'parcel').toList();
    } else {
      filtered = allServices;
    }

    return MasterDashboardState(
      services: filtered,
      totalOrders: orders.allOrders.length,
      totalEarnings: earnings.todayEarnings,
      completionRate: orders.overallCompletionRate,
    );
  }

  bool toggleService(int index) {
    if (index < 0 || index >= state.services.length) return false;
    final service = state.services[index];
    final newValue = !service.isOnline;
    
    // Update the source of truth provider
    ref.read(serviceStatusProvider.notifier).setOnline(service.serviceId, newValue);
    
    // Note: Re-setting 'state' here is actually redundant because build() 
    // will re-fire as soon as serviceStatusProvider changes.
    return newValue;
  }

  bool toggleServiceById(String serviceId) {
    final index = state.services.indexWhere((s) => s.serviceId == serviceId);
    if (index != -1) return toggleService(index);
    return false;
  }
}

