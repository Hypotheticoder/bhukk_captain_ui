import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bhukkdelivery/providers/orders/orders_provider.dart';
import 'package:bhukkdelivery/providers/earnings/earnings_provider.dart';

class MedicineState {
  final int totalMedicines;
  final int deliveredMedicines;
  final int pendingMedicines;
  final double earnings;
  final double avgWeight; // kg

  const MedicineState({
    required this.totalMedicines,
    required this.deliveredMedicines,
    required this.pendingMedicines,
    required this.earnings,
    this.avgWeight = 2.4, // Average medicine weight is smaller
  });

  double get deliveryRate =>
      totalMedicines > 0 ? (deliveredMedicines / totalMedicines) * 100 : 0;

  double get avgEarnings =>
      deliveredMedicines > 0 ? earnings / deliveredMedicines : 0;
}

class MedicineNotifier extends Notifier<MedicineState> {
  @override
  MedicineState build() {
    final orders = ref.watch(ordersProvider).allOrders.where((o) => o.serviceType == 'medicine').toList();
    final earningsState = ref.watch(earningsProvider);

    final total = orders.length;
    final delivered = orders.where((o) => o.status == OrderStatus.completed).length;
    final pending = orders.where((o) => o.status == OrderStatus.inProgress).length;
    final totalEarnings = earningsState.medicineEarnings;

    return MedicineState(
      totalMedicines: total,
      deliveredMedicines: delivered,
      pendingMedicines: pending,
      earnings: totalEarnings,
      avgWeight: 2.4,
    );
  }
}
