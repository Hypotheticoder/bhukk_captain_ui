import 'package:flutter_riverpod/flutter_riverpod.dart';

class FoodDeliveryState {
  final int totalOrders;
  final int completedOrders;
  final int canceledOrders;
  final double earnings;
  final double onTimePercentage;

  const FoodDeliveryState({
    this.totalOrders = 32,
    this.completedOrders = 30,
    this.canceledOrders = 2,
    this.earnings = 4800,
    this.onTimePercentage = 94.5,
  });

  double get completionRate =>
      totalOrders > 0 ? (completedOrders / totalOrders) * 100 : 0;

  double get avgEarnings =>
      completedOrders > 0 ? earnings / completedOrders : 0;
}

class FoodDeliveryNotifier extends Notifier<FoodDeliveryState> {
  @override
  FoodDeliveryState build() => const FoodDeliveryState();
}
