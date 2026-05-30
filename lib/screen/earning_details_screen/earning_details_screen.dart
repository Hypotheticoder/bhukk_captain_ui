import 'package:bhukkdelivery/cards/earning_details_screen/income_source_pie_card.dart';
import 'package:bhukkdelivery/cards/earning_details_screen/summary_chart_card.dart';
import 'package:bhukkdelivery/cards/earning_details_screen/transaction_history_card.dart';
import 'package:bhukkdelivery/notifiers/orders_screen/orders_notifier.dart';
import 'package:bhukkdelivery/providers/earnings/earnings_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EarningDetailsScreen extends ConsumerWidget {
  const EarningDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = C.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          "Earning Analytics",
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Service filter chips ──
            Text(
              "SERVICE",
              style: AppTextStyles.overline.copyWith(
                color: colors.textTertiary,
                fontSize: 10,
                letterSpacing: 1.8,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 40,
              child: Consumer(
                builder: (context, ref, child) {
                  final state = ref.watch(earningsProvider);
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.availableFilters.length,
                    separatorBuilder: (_, index) =>
                        const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final isActive = index == state.selectedServiceIndex;
                      final label = state.availableFilters[index];
                      final svcKey = label.toLowerCase();
                      
                      // Custom mapping for Ride and Parcel icons/colors
                      Color color;
                      IconData icon;
                      
                      if (svcKey == 'all') {
                        color = AppColors.primary;
                        icon = Icons.apps_rounded;
                      } else if (svcKey == 'ride') {
                        color = AppColors.primary;
                        icon = Icons.electric_moped_rounded;
                      } else if (svcKey == 'parcel') {
                        color = AppColors.success;
                        icon = Icons.inventory_2_rounded;
                      } else {
                        final meta = serviceMetaMap[svcKey];
                        color = meta?.color ?? AppColors.primary;
                        icon = meta?.icon ?? Icons.apps_rounded;
                      }

                      return GestureDetector(
                        onTap: () => ref
                            .read(earningsProvider.notifier)
                            .selectServiceFilter(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md + 2,
                          ),
                          decoration: BoxDecoration(
                            color: isActive ? color : colors.surfaceElevated,
                            borderRadius: AppRadius.pillAll,
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: color.withAlpha(80),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: colors.cardShadow(0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                index == 0 ? Icons.apps_rounded : icon,
                                size: 14,
                                color: isActive
                                    ? Colors.white
                                    : colors.textTertiary,
                              ),
                              const SizedBox(width: AppSpacing.xs + 2),
                              Text(
                                label,
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? Colors.white
                                      : colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Charts and transactions ──
            const SummaryChartCard(),
            const SizedBox(height: AppSpacing.xxl),
            const IncomeSourcePieCard(),
            const SizedBox(height: AppSpacing.xxl),
            const TransactionHistoryCard(),
            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
    );
  }
}
