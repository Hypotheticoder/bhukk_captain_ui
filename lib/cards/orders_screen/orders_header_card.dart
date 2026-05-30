import 'package:bhukkdelivery/providers/orders/orders_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrdersHeaderCard extends ConsumerWidget {
  const OrdersHeaderCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = C.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order History",
                    style: AppTextStyles.headingLg.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    "All services • Track your deliveries",
                    style: AppTextStyles.bodySm.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm + 2),
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: AppRadius.mdAll,
                boxShadow: [
                  BoxShadow(
                    color: colors.cardShadow(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.sort_rounded,
                color: colors.textSecondary,
                size: 22,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        // Search bar
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: AppRadius.pillAll,
            boxShadow: [
              BoxShadow(
                color: colors.cardShadow(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: colors.blush.withAlpha(colors.isDark ? 30 : 80),
              width: 0.5,
            ),
          ),
          child: TextField(
            onChanged: (v) =>
                ref.read(ordersProvider.notifier).searchOrders(v),
            style: AppTextStyles.bodySm.copyWith(color: colors.textPrimary),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: "Search orders, restaurants...",
              hintStyle: AppTextStyles.bodySm.copyWith(
                color: colors.textTertiary,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: colors.textTertiary,
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md + 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
