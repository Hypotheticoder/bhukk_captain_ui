import 'package:bhukkdelivery/providers/earnings/earnings_provider.dart';
import 'package:bhukkdelivery/providers/orders/orders_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EarningsCard extends ConsumerStatefulWidget {
  const EarningsCard({super.key});

  @override
  ConsumerState<EarningsCard> createState() => _EarningsCardState();
}

class _EarningsCardState extends ConsumerState<EarningsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _lineAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _lineAnim = CurvedAnimation(
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
    final earningsState = ref.watch(earningsProvider);
    final ordersState = ref.watch(ordersProvider);

    // Use the live weekly earnings data from backend for sparkline
    final List<double> chartData = earningsState.weeklyBarData;

    return GestureDetector(
      onTap: () => context.go('/earnings'),
      child: AnimatedBuilder(
        animation: _lineAnim,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: colors.elevatedCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm + 2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withAlpha(colors.isDark ? 50 : 30),
                                AppColors.primaryAccent.withAlpha(colors.isDark ? 30 : 15),
                              ],
                            ),
                            borderRadius: AppRadius.mdAll,
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm + 2,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successLight.withAlpha(
                              colors.isDark ? 40 : 255,
                            ),
                            borderRadius: AppRadius.pillAll,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.trending_up_rounded,
                                size: 12,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                earningsState.monthGrowth >= 0 
                                  ? "+${earningsState.monthGrowth.toInt()}%"
                                  : "${earningsState.monthGrowth.toInt()}%",
                                style: AppTextStyles.caption.copyWith(
                                  color: earningsState.monthGrowth >= 0 ? AppColors.success : AppColors.error,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: colors.textTertiary,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Today's Earnings",
                            style: AppTextStyles.bodySm.copyWith(
                              color: colors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            "₹ ${earningsState.todayEarnings.toStringAsFixed(2)}",
                            style: AppTextStyles.earningsMd.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      height: 45,
                      child: chartData.any((v) => v > 0)
                          ? LineChart(
                              LineChartData(
                                gridData: const FlGridData(show: false),
                                titlesData: const FlTitlesData(show: false),
                                borderData: FlBorderData(show: false),
                                minX: 0,
                                maxX: (chartData.length - 1).clamp(1, 100).toDouble(),
                                minY: 0,
                                maxY: (chartData.fold<double>(0, (max, v) => v > max ? v : max) * 1.2).clamp(1, double.infinity),
                                lineTouchData: const LineTouchData(enabled: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: List.generate(
                                      chartData.length,
                                      (i) => FlSpot(
                                        i.toDouble(),
                                        chartData[i] * _lineAnim.value,
                                      ),
                                    ),
                                    isCurved: true,
                                    curveSmoothness: 0.3,
                                    color: AppColors.primary,
                                    barWidth: 2.5,
                                    isStrokeCapRound: true,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          AppColors.primary.withAlpha(colors.isDark ? 60 : 40),
                                          AppColors.primary.withAlpha(5),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.show_chart_rounded,
                                size: 24,
                                color: colors.textTertiary.withAlpha(60),
                              ),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                Container(height: 1, color: colors.divider),
                const SizedBox(height: AppSpacing.md),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMiniStat(
                      icon: Icons.receipt_long_rounded,
                      text: "${ordersState.totalOrders} Orders",
                      color: AppColors.primary,
                      colors: colors,
                    ),
                    _buildMiniStat(
                      icon: Icons.timer_outlined,
                      text: "Today",
                      color: AppColors.info,
                      colors: colors,
                    ),
                    _buildMiniStat(
                      icon: Icons.trending_up_rounded,
                      text: "${(ordersState.completionRate * 100).toInt()}% Rate",
                      color: AppColors.success,
                      colors: colors,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String text,
    required Color color,
    required C colors,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withAlpha(colors.isDark ? 35 : 20),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 13, color: color),
        ),
        const SizedBox(width: AppSpacing.xs + 2),
        Text(
          text,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
