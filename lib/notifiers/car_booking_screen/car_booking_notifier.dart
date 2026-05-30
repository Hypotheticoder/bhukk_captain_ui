import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bhukkdelivery/providers/orders/orders_provider.dart';
import 'package:bhukkdelivery/providers/earnings/earnings_provider.dart';

class CarBookingState {
  final int totalRides;
  final int completedRides;
  final int activeRides;
  final double earnings;
  final double avgWaitTime; // minutes

  const CarBookingState({
    required this.totalRides,
    required this.completedRides,
    required this.activeRides,
    required this.earnings,
    this.avgWaitTime = 4.2,
  });

  double get completionRate =>
      totalRides > 0 ? (completedRides / totalRides) * 100 : 0;

  double get avgEarnings =>
      completedRides > 0 ? earnings / completedRides : 0;
}

class CarBookingNotifier extends Notifier<CarBookingState> {
  @override
  CarBookingState build() {
    final orders = ref.watch(ordersProvider).allOrders.where((o) => o.serviceType == 'ride').toList();
    final earningsState = ref.watch(earningsProvider);

    final total = orders.length;
    final completed = orders.where((o) => o.status == OrderStatus.completed).length;
    final active = orders.where((o) => o.status == OrderStatus.inProgress).length;
    final totalEarnings = earningsState.rideEarnings;

    return CarBookingState(
      totalRides: total,
      completedRides: completed,
      activeRides: active,
      earnings: totalEarnings,
      avgWaitTime: 4.2,
    );
  }
}
