import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bhukkdelivery/providers/orders/orders_provider.dart';
import 'package:bhukkdelivery/providers/earnings/earnings_provider.dart';

class ParcelState {
  final int totalParcels;
  final int deliveredParcels;
  final int pendingParcels;
  final double earnings;
  final double avgWeight; // kg

  const ParcelState({
    required this.totalParcels,
    required this.deliveredParcels,
    required this.pendingParcels,
    required this.earnings,
    this.avgWeight = 12.4,
  });

  double get deliveryRate =>
      totalParcels > 0 ? (deliveredParcels / totalParcels) * 100 : 0;

  double get avgEarnings =>
      deliveredParcels > 0 ? earnings / deliveredParcels : 0;
}

class ParcelNotifier extends Notifier<ParcelState> {
  @override
  ParcelState build() {
    final orders = ref.watch(ordersProvider).allOrders.where((o) => o.serviceType == 'parcel').toList();
    final earningsState = ref.watch(earningsProvider);

    final total = orders.length;
    final delivered = orders.where((o) => o.status == OrderStatus.completed).length;
    final pending = orders.where((o) => o.status == OrderStatus.inProgress).length;
    final totalEarnings = earningsState.parcelEarnings;

    return ParcelState(
      totalParcels: total,
      deliveredParcels: delivered,
      pendingParcels: pending,
      earnings: totalEarnings,
      avgWeight: 12.4,
    );
  }
}
