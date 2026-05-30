import 'package:bhukkdelivery/providers/earnings/earnings_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SummaryChartCard extends ConsumerStatefulWidget {
  const SummaryChartCard({super.key});

  @override
  ConsumerState<SummaryChartCard> createState() => _SummaryChartCardState();
}

class _SummaryChartCardState extends ConsumerState<SummaryChartCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _barAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _barAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  static const List<String> _dayLabels = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  String _formatAmount(double val) {
    if (val >= 1000) {
      final k = val / 1000;
      final remainder = val % 1000;
      if (remainder == 0) return "${k.toStringAsFixed(0)},000";
      return "${k.floor()},${remainder.toStringAsFixed(0).padLeft(3, '0')}";
    }
    return val.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    final state = ref.watch(earningsProvider);
    final weeklyData = state.weeklyBarData;
    final weekTotal = state.thisWeekEarnings;
    
    final maxVal = (weeklyData.isEmpty) ? 100.0 : weeklyData.reduce((a, b) => a > b ? a : b);
    final maxY = maxVal == 0 ? 100.0 : maxVal * 1.3;
    final todayIndex = DateTime.now().weekday - 1;

    final svcColor = state.selectedServiceIndex == 0
        ? AppColors.primary
        : state.selectedServiceColor;

    return AnimatedBuilder(
      animation: _barAnimation,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Overview",
                        style: AppTextStyles.headingSm.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        "Last 7 days earnings",
                        style: AppTextStyles.bodySm.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "₹ ${_formatAmount(weekTotal)}",
                    style: AppTextStyles.headingMd.copyWith(
                      color: svcColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    minY: 0,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) =>
                            colors.textPrimary.withAlpha(230),
                        tooltipPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            "₹${weeklyData[groupIndex].toInt()}",
                            AppTextStyles.caption.copyWith(
                              color: colors.isDark
                                  ? Colors.black
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= _dayLabels.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _dayLabels[idx],
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 11,
                                  color: idx == todayIndex
                                      ? svcColor
                                      : colors.textTertiary,
                                  fontWeight: idx == todayIndex
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(7, (i) {
                      final isToday = i == todayIndex;
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: weeklyData[i] * _barAnimation.value,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                            gradient: isToday
                                ? LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      svcColor.withAlpha(180),
                                      svcColor,
                                    ],
                                  )
                                : LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      colors.blush.withAlpha(
                                          colors.isDark ? 100 : 180),
                                      colors.blush,
                                    ],
                                  ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
