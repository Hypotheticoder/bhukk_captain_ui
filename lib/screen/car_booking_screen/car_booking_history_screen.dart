import 'package:bhukkdelivery/cards/car_booking_screen/car_booking_history_card.dart';
import 'package:bhukkdelivery/providers/orders/orders_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CarBookingHistoryScreen extends ConsumerWidget {
  const CarBookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = C.of(context);
    final orders = ref.watch(ordersProvider.select(
      (s) => s.allOrders.where((o) => o.serviceType == 'ride').toList(),
    ));

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Cab History',
          style: AppTextStyles.headingMd.copyWith(color: colors.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: AppSpacing.lg,
          bottom: 120,
        ),
        child: Column(
          children: [
            if (orders.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Column(
                    children: [
                      Icon(Icons.history_rounded, size: 64, color: colors.textTertiary.withAlpha(80)),
                      const SizedBox(height: AppSpacing.md),
                      Text("No ride history found", style: AppTextStyles.bodyMd.copyWith(color: colors.textTertiary)),
                    ],
                  ),
                ),
              )
            else
              ...List.generate(orders.length, (i) {
                final o = orders[i];
                final r = {
                  'title': o.storeName,
                  'date': o.dateTime.toString().substring(0, 16),
                  'distance': '${o.distanceKm.toStringAsFixed(1)} km',
                  'duration': '${o.durationMin} min',
                  'fare': '₹${o.amount.toInt()}',
                  'status': o.status.name.substring(0, 1).toUpperCase() + o.status.name.substring(1),
                };
                return Column(
                  children: [
                    CarBookingHistoryCard(ride: r),
                    if (i < orders.length - 1)
                      const SizedBox(height: AppSpacing.lg),
                  ],
                );
              }),
            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
    );
  }
}
