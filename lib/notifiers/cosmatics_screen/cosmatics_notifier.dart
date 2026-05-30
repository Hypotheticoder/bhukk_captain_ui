import 'package:flutter_riverpod/flutter_riverpod.dart';

class CosmaticsState {
  final int totalOrders;
  final int completedOrders;
  final int pendingOrders;
  final double earnings;
  final double avgItemCount;

  const CosmaticsState({
    this.totalOrders = 26,
    this.completedOrders = 22,
    this.pendingOrders = 4,
    this.earnings = 5340,
    this.avgItemCount = 3.1,
  });

  double get completionRate =>
      totalOrders > 0 ? (completedOrders / totalOrders) * 100 : 0;

  double get avgEarningsPerOrder =>
      completedOrders > 0 ? earnings / completedOrders : 0;
}

class CosmaticsNotifier extends Notifier<CosmaticsState> {
  @override
  CosmaticsState build() => const CosmaticsState();
}
