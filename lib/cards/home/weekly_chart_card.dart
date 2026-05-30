import 'package:bhukkdelivery/providers/earnings/earnings_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ChartPeriod { weekly, monthly }

class WeeklyChartCard extends ConsumerStatefulWidget {
  const WeeklyChartCard({super.key});

  @override
  ConsumerState<WeeklyChartCard> createState() => _WeeklyChartCardState();
}

class _WeeklyChartCardState extends ConsumerState<WeeklyChartCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _barAnimation;
  ChartPeriod _selectedPeriod = ChartPeriod.weekly;

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

  void _switchPeriod(ChartPeriod period) {
    if (period == _selectedPeriod) return;
    setState(() => _selectedPeriod = period);
    _animController.forward(from: 0);
  }

  _ChartData _getActiveData(EarningsState earningsState) {
    switch (_selectedPeriod) {
      case ChartPeriod.weekly:
        final List<double> values = earningsState.weeklyBarData;
        final total = values.fold<double>(0.0, (sum, v) => sum + v);
        double maxVal = values.fold<double>(0.0, (prev, v) => v > prev ? v : prev);
        if (maxVal < 1) maxVal = 100; // Avoid 0-max chart

        return _ChartData(
          values: values,
          labels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          maxY: maxVal * 1.2,
          total: '₹ ${total.toStringAsFixed(0)}',
          highlightIndex: DateTime.now().weekday - 1,
        );

      case ChartPeriod.monthly:
        // Derive monthly view from available backend data
        // Show: Ride earnings, Parcel earnings, COD collected, Commission owed
        final rideE = earningsState.rideEarnings;
        final parcelE = earningsState.parcelEarnings;
        final codE = earningsState.codEarnings;
        final onlineE = earningsState.onlineEarnings;

        final values = <double>[rideE, parcelE, codE, onlineE];
        final labels = <String>['Ride', 'Parcel', 'COD', 'Online'];

        // Filter out zero categories for cleaner chart
        final filteredValues = <double>[];
        final filteredLabels = <String>[];
        for (int i = 0; i < values.length; i++) {
          if (values[i] > 0) {
            filteredValues.add(values[i]);
            filteredLabels.add(labels[i]);
          }
        }

        // Fallback if everything is 0
        if (filteredValues.isEmpty) {
          filteredValues.add(0);
          filteredLabels.add('No Data');
        }

        final total = filteredValues.fold<double>(0.0, (s, v) => s + v);
        double maxVal = filteredValues.fold<double>(0.0, (prev, v) => v > prev ? v : prev);
        if (maxVal < 1) maxVal = 100;

        // Highlight the largest bar
        int highlightIdx = 0;
        for (int i = 1; i < filteredValues.length; i++) {
          if (filteredValues[i] > filteredValues[highlightIdx]) highlightIdx = i;
        }

        return _ChartData(
          values: filteredValues,
          labels: filteredLabels,
          maxY: maxVal * 1.2,
          total: '₹ ${total.toStringAsFixed(0)}',
          highlightIndex: highlightIdx,
        );
    }
  }

  String get _periodLabel {
    switch (_selectedPeriod) {
      case ChartPeriod.weekly:
        return 'Weekly Earnings';
      case ChartPeriod.monthly:
        return 'Earnings Breakdown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    final earningsState = ref.watch(earningsProvider);
    final data = _getActiveData(earningsState);

    final bool hasData = data.values.any((v) => v > 0);

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
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _periodLabel,
                        style: AppTextStyles.headingSm.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        hasData ? "${data.total} total" : "No earnings yet",
                        style: AppTextStyles.bodySm.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  if (earningsState.isLoading)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.textTertiary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Period tabs
              _buildPeriodTabs(colors),
              const SizedBox(height: AppSpacing.xxl),

              // Chart
              SizedBox(
                height: 160,
                child: hasData
                    ? BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: data.maxY,
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
                                  "₹${data.values[groupIndex].toInt()}",
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
                                  if (idx >= data.labels.length) {
                                    return const SizedBox.shrink();
                                  }
                                  final isHighlight = idx == data.highlightIndex;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      data.labels[idx],
                                      style: AppTextStyles.caption.copyWith(
                                        fontSize: 11,
                                        color: isHighlight
                                            ? AppColors.primary
                                            : colors.textTertiary,
                                        fontWeight: isHighlight
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: List.generate(data.values.length, (i) {
                            final isHighlight = i == data.highlightIndex;
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: data.values[i] * _barAnimation.value,
                                  width: data.values.length <= 4 ? 32 : 20,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                  gradient: isHighlight
                                      ? const LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            AppColors.darkCyan,
                                            AppColors.primary,
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
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bar_chart_rounded,
                              size: 40,
                              color: colors.textTertiary.withAlpha(80),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              "Complete orders to see chart",
                              style: AppTextStyles.bodySm.copyWith(
                                color: colors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPeriodTabs(C colors) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.blush.withAlpha(colors.isDark ? 40 : 80),
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        children: ChartPeriod.values.map((period) {
          final isSelected = period == _selectedPeriod;
          final label = switch (period) {
            ChartPeriod.weekly => 'This Week',
            ChartPeriod.monthly => 'Breakdown',
          };

          return Expanded(
            child: GestureDetector(
              onTap: () => _switchPeriod(period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (colors.isDark ? AppColors.darkCyan : Colors.white)
                      : Colors.transparent,
                  borderRadius: AppRadius.pillAll,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colors.cardShadow(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected
                          ? colors.textPrimary
                          : colors.textTertiary,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ChartData {
  final List<double> values;
  final List<String> labels;
  final double maxY;
  final String total;
  final int highlightIndex;

  const _ChartData({
    required this.values,
    required this.labels,
    required this.maxY,
    required this.total,
    required this.highlightIndex,
  });
}
