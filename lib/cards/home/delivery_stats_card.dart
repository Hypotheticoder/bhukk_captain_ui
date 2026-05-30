import 'dart:math';
import 'package:bhukkdelivery/providers/orders/orders_provider.dart';
import 'package:bhukkdelivery/providers/profile/profile_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeliveryStatsCard extends ConsumerStatefulWidget {
  const DeliveryStatsCard({super.key});

  @override
  ConsumerState<DeliveryStatsCard> createState() => _DeliveryStatsCardState();
}

class _DeliveryStatsCardState extends ConsumerState<DeliveryStatsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _ringAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _ringAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    final ordersState = ref.watch(ordersProvider);
    final profileState = ref.watch(profileProvider);

    final orders = ordersState.allOrders;
    final completedCount = orders.where((o) => o.status == OrderStatus.completed).length;
    final cancelledCount = orders.where((o) => o.status == OrderStatus.cancelled).length;
    final pendingCount = orders.length - completedCount - cancelledCount;
    
    final totalTarget = max(10, orders.length);
    final rating = profileState?.rating ?? 4.8;

    return AnimatedBuilder(
      animation: _ringAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: colors.elevatedCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today's Performance",
                style: AppTextStyles.headingSm.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              Row(
                children: [
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            startDegreeOffset: -90,
                            sectionsSpace: 3,
                            centerSpaceRadius: 35,
                            sections: [
                              PieChartSectionData(
                                value: (completedCount.toDouble() * _ringAnimation.value).clamp(0.01, double.infinity),
                                color: AppColors.primary,
                                radius: 16,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: max(0.01, (totalTarget.toDouble() - completedCount.toDouble() * _ringAnimation.value)),
                                color: colors.blush.withAlpha(colors.isDark ? 60 : 100),
                                radius: 14,
                                showTitle: false,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${(completedCount * _ringAnimation.value).toInt()}",
                              style: AppTextStyles.headingMd.copyWith(
                                color: AppColors.primary,
                                fontSize: 24,
                              ),
                            ),
                            Text(
                              "of $totalTarget",
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 10,
                                color: colors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xl),

                  Expanded(
                    child: Column(
                      children: [
                        _buildStatRow(
                          icon: Icons.check_circle_rounded,
                          color: AppColors.success,
                          label: "Completed",
                          value: "$completedCount",
                          colors: colors,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildStatRow(
                          icon: Icons.pending_rounded,
                          color: AppColors.warning,
                          label: "Pending",
                          value: "$pendingCount",
                          colors: colors,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildStatRow(
                          icon: Icons.cancel_rounded,
                          color: AppColors.error,
                          label: "Cancelled",
                          value: "$cancelledCount",
                          colors: colors,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildStatRow(
                          icon: Icons.star_rounded,
                          color: AppColors.starYellow,
                          label: "Avg Rating",
                          value: rating.toStringAsFixed(1),
                          colors: colors,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required C colors,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withAlpha(colors.isDark ? 35 : 25),
            borderRadius: AppRadius.smAll,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(color: colors.textTertiary),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMd.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
