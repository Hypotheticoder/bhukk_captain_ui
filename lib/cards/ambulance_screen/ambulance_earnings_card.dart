import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AmbulanceEarningsCard extends StatefulWidget {
  const AmbulanceEarningsCard({super.key});

  @override
  State<AmbulanceEarningsCard> createState() => _AmbulanceEarningsCardState();
}

class _AmbulanceEarningsCardState extends State<AmbulanceEarningsCard>
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

  static const List<double> _hourlyData = [
    200, 350, 280, 450, 380, 520, 460, 600, 540, 680, 620, 750
  ];

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return AnimatedBuilder(
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
                              AppColors.ambulance.withAlpha(
                                colors.isDark ? 50 : 30,
                              ),
                              AppColors.ambulance.withAlpha(
                                colors.isDark ? 30 : 15,
                              ),
                            ],
                          ),
                          borderRadius: AppRadius.mdAll,
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: AppColors.ambulance,
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
                              "+22%",
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.success,
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
                          "Ambulance Earnings",
                          style: AppTextStyles.bodySm.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          "₹ 4,860.00",
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
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: 11,
                        minY: 100,
                        maxY: 800,
                        lineTouchData: const LineTouchData(enabled: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              12,
                              (i) => FlSpot(
                                i.toDouble(),
                                _hourlyData[i] * _lineAnim.value,
                              ),
                            ),
                            isCurved: true,
                            curveSmoothness: 0.3,
                            color: AppColors.ambulance,
                            barWidth: 2.5,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.ambulance.withAlpha(
                                    colors.isDark ? 60 : 40,
                                  ),
                                  AppColors.ambulance.withAlpha(5),
                                ],
                              ),
                            ),
                          ),
                        ],
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
                    icon: Icons.local_hospital_rounded,
                    text: "16 Rides",
                    color: AppColors.ambulance,
                    colors: colors,
                  ),
                  _buildMiniStat(
                    icon: Icons.timer_outlined,
                    text: "5.8 hrs",
                    color: AppColors.info,
                    colors: colors,
                  ),
                  _buildMiniStat(
                    icon: Icons.trending_up_rounded,
                    text: "₹838/hr",
                    color: AppColors.success,
                    colors: colors,
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
