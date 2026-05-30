import 'package:flutter_riverpod/flutter_riverpod.dart';

class BeveragesState {
  final int totalOrders;
  final int completedOrders;
  final double earnings;
  final double avgRating;

  const BeveragesState({
    this.totalOrders = 24,
    this.completedOrders = 21,
    this.earnings = 4820,
    this.avgRating = 4.6,
  });

  double get completionRate =>
      totalOrders > 0 ? (completedOrders / totalOrders) * 100 : 0;

  double get avgEarnings =>
      completedOrders > 0 ? earnings / completedOrders : 0;
}

class BeveragesNotifier extends Notifier<BeveragesState> {
  @override
  BeveragesState build() => const BeveragesState();
}
