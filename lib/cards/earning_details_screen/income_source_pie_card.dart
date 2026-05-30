import 'package:bhukkdelivery/providers/earnings/earnings_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IncomeSourcePieCard extends ConsumerStatefulWidget {
  const IncomeSourcePieCard({super.key});

  @override
  ConsumerState<IncomeSourcePieCard> createState() =>
      _IncomeSourcePieCardState();
}

class _IncomeSourcePieCardState extends ConsumerState<IncomeSourcePieCard>
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

  // Color mapping for categories
  static const Map<String, Color> _categoryColors = {
    'ride': AppColors.primary,
    'parcel': AppColors.success,
    'cod': Color(0xFFF59E0B),     // Amber
    'online': Color(0xFF6366F1),  // Indigo
    'bonus': AppColors.starYellow,
    'tip': Color(0xFF10B981),
  };

  static const Map<String, IconData> _categoryIcons = {
    'ride': Icons.directions_car_rounded,
    'parcel': Icons.inventory_2_rounded,
    'cod': Icons.payments_rounded,
    'online': Icons.credit_card_rounded,
    'bonus': Icons.stars_rounded,
    'tip': Icons.volunteer_activism_rounded,
  };

  Color _colorForCategory(String category) {
    final key = category.toLowerCase();
    return _categoryColors[key] ?? AppColors.primary;
  }

  IconData _iconForCategory(String category) {
    final key = category.toLowerCase();
    return _categoryIcons[key] ?? Icons.pie_chart_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    final state = ref.watch(earningsProvider);

    // Build pie data from backend income_pie + COD/Online split
    final List<_PieEntry> entries = [];

    if (state.incomePie.isNotEmpty) {
      // Use the actual backend Ride/Parcel pie breakdown
      for (final slice in state.incomePie) {
        entries.add(_PieEntry(
          label: slice.category,
          amount: slice.amount,
          percentage: slice.percentage,
          color: _colorForCategory(slice.category),
        ));
      }
    } else if (state.rideEarnings > 0 || state.parcelEarnings > 0) {
      // Fallback: derive from breakdown balances
      final total = state.rideEarnings + state.parcelEarnings;
      if (state.rideEarnings > 0) {
        entries.add(_PieEntry(
          label: 'Ride',
          amount: state.rideEarnings,
          percentage: total > 0 ? (state.rideEarnings / total * 100) : 0,
          color: AppColors.primary,
        ));
      }
      if (state.parcelEarnings > 0) {
        entries.add(_PieEntry(
          label: 'Parcel',
          amount: state.parcelEarnings,
          percentage: total > 0 ? (state.parcelEarnings / total * 100) : 0,
          color: AppColors.success,
        ));
      }
    }

    final bool hasData = entries.isNotEmpty;

    // Also build COD vs Online summary from transactions
    final hasCodOnline = state.codEarnings > 0 || state.onlineEarnings > 0;
    final codOnlineTotal = state.codEarnings + state.onlineEarnings;

    return AnimatedBuilder(
      animation: _ringAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: colors.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Income Breakdown",
                style: AppTextStyles.headingSm.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Pie Chart + Legend ──
              Row(
                children: [
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            startDegreeOffset: -90,
                            sectionsSpace: 4,
                            centerSpaceRadius: 40,
                            sections: hasData
                                ? entries.asMap().entries.map((e) {
                                    final idx = e.key;
                                    final entry = e.value;
                                    return PieChartSectionData(
                                      value: entry.percentage * _ringAnimation.value,
                                      color: entry.color,
                                      radius: 18 - (idx * 2).clamp(0, 6).toDouble(),
                                      showTitle: false,
                                    );
                                  }).toList()
                                : [
                                    PieChartSectionData(
                                      value: 100,
                                      color: colors.divider,
                                      radius: 16,
                                      showTitle: false,
                                    ),
                                  ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasData
                                  ? Icons.pie_chart_rounded
                                  : Icons.hourglass_empty_rounded,
                              size: 20,
                              color: hasData
                                  ? colors.textPrimary
                                  : colors.textTertiary,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              hasData ? "Split" : "No Data",
                              style: AppTextStyles.caption.copyWith(
                                color: colors.textTertiary,
                                fontSize: 10,
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
                        if (hasData)
                          ...entries.map((entry) => Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppSpacing.md),
                                child: _buildLegendRow(
                                  color: entry.color,
                                  icon: _iconForCategory(entry.label),
                                  label: entry.label,
                                  amount: "₹${entry.amount.toStringAsFixed(0)}",
                                  percentage:
                                      "${entry.percentage.toStringAsFixed(0)}%",
                                  colors: colors,
                                ),
                              ))
                        else
                          Text(
                            "Complete orders to see\nyour earning split",
                            style: AppTextStyles.bodySm.copyWith(
                              color: colors.textTertiary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              // ── COD vs Online summary ──
              if (hasCodOnline) ...[
                const SizedBox(height: AppSpacing.xl),
                Divider(color: colors.divider, height: 1),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  "PAYMENT MODE",
                  style: AppTextStyles.overline.copyWith(
                    color: colors.textTertiary,
                    fontSize: 10,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    if (state.codEarnings > 0)
                      Expanded(
                        child: _PaymentModeChip(
                          icon: Icons.payments_rounded,
                          label: "COD",
                          amount: "₹${state.codEarnings.toStringAsFixed(0)}",
                          percentage: codOnlineTotal > 0
                              ? "${(state.codEarnings / codOnlineTotal * 100).toStringAsFixed(0)}%"
                              : "0%",
                          color: const Color(0xFFF59E0B),
                          colors: colors,
                        ),
                      ),
                    if (state.codEarnings > 0 && state.onlineEarnings > 0)
                      const SizedBox(width: AppSpacing.md),
                    if (state.onlineEarnings > 0)
                      Expanded(
                        child: _PaymentModeChip(
                          icon: Icons.credit_card_rounded,
                          label: "Online",
                          amount: "₹${state.onlineEarnings.toStringAsFixed(0)}",
                          percentage: codOnlineTotal > 0
                              ? "${(state.onlineEarnings / codOnlineTotal * 100).toStringAsFixed(0)}%"
                              : "0%",
                          color: const Color(0xFF6366F1),
                          colors: colors,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendRow({
    required Color color,
    required IconData icon,
    required String label,
    required String amount,
    required String percentage,
    required C colors,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withAlpha(colors.isDark ? 35 : 20),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySm.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                amount,
                style: AppTextStyles.caption.copyWith(
                  color: colors.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Text(
          percentage,
          style: AppTextStyles.bodySm.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PaymentModeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String amount;
  final String percentage;
  final Color color;
  final C colors;

  const _PaymentModeChip({
    required this.icon,
    required this.label,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withAlpha(colors.isDark ? 20 : 12),
        borderRadius: AppRadius.lgAll,
        border: Border.all(
          color: color.withAlpha(colors.isDark ? 40 : 25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: colors.textTertiary,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
                Text(
                  amount,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            percentage,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PieEntry {
  final String label;
  final double amount;
  final double percentage;
  final Color color;

  const _PieEntry({
    required this.label,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}
