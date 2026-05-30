import 'package:flutter_riverpod/flutter_riverpod.dart';

class HeavyDeliveryState {
  final int totalLoads;
  final int deliveredLoads;
  final int pendingLoads;
  final double earnings;
  final double totalWeightKg; // total kg moved today

  const HeavyDeliveryState({
    this.totalLoads = 12,
    this.deliveredLoads = 9,
    this.pendingLoads = 3,
    this.earnings = 18500,
    this.totalWeightKg = 2450,
  });

  double get deliveryRate =>
      totalLoads > 0 ? (deliveredLoads / totalLoads) * 100 : 0;

  double get avgEarnings =>
      deliveredLoads > 0 ? earnings / deliveredLoads : 0;

  double get avgWeightPerLoad =>
      deliveredLoads > 0 ? totalWeightKg / deliveredLoads : 0;
}

class HeavyDeliveryNotifier extends Notifier<HeavyDeliveryState> {
  @override
  HeavyDeliveryState build() => const HeavyDeliveryState();
}
