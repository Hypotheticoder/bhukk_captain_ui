import 'package:bhukkdelivery/providers/earnings/earnings_provider.dart';
import 'package:bhukkdelivery/providers/profile/profile_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A premium card that explains the platform's fee structure, GST,
/// and per-km rates specific to the logged-in driver's vehicle type.
///
/// Designed to build rider trust by transparently showing how their
/// earnings are calculated before any deductions.
class GstBreakdownCard extends ConsumerWidget {
  const GstBreakdownCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = C.of(context);
    final config = ref.watch(earningsProvider.select((s) => s.earningConfig));
    final profile = ref.watch(profileProvider);

    if (config == null || config.isEmpty) return const SizedBox.shrink();

    // Determine the vehicle icon and label
    final vehicleType = profile?.vehicleType ?? 'bike';
    final vehicleInfo = _getVehicleInfo(vehicleType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ──
        Text(
          "FEE STRUCTURE",
          style: AppTextStyles.overline.copyWith(
            color: colors.textTertiary,
            fontSize: 10,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          "How your earnings are calculated",
          style: AppTextStyles.bodySm.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Main card ──
        Container(
          decoration: colors.borderedCard,
          clipBehavior: Clip.hardEdge,
          child: Column(
            children: [
              // ── Vehicle badge header ──
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withAlpha(colors.isDark ? 25 : 15),
                      AppColors.secondaryCyan.withAlpha(colors.isDark ? 15 : 8),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(colors.isDark ? 40 : 25),
                        borderRadius: AppRadius.smAll,
                      ),
                      child: Icon(
                        vehicleInfo.icon,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            config.vehicleLabel.isNotEmpty
                                ? config.vehicleLabel
                                : vehicleInfo.label,
                            style: AppTextStyles.bodyLg.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Your fare structure",
                            style: AppTextStyles.caption.copyWith(
                              color: colors.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(colors.isDark ? 30 : 18),
                        borderRadius: AppRadius.pillAll,
                        border: Border.all(
                          color: AppColors.primary.withAlpha(colors.isDark ? 50 : 30),
                        ),
                      ),
                      child: Text(
                        "LIVE",
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Static pricing rows (base fare, per-km) ──
              if (config.baseFare > 0 || config.perKmRate > 0) ...[
                _SectionDivider(colors: colors),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.lg,
                  ),
                  child: Row(
                    children: [
                      if (config.baseFare > 0)
                        Expanded(
                          child: _MiniStat(
                            icon: Icons.flag_rounded,
                            label: "Base Fare",
                            value: "₹${config.baseFare.toStringAsFixed(0)}",
                            color: AppColors.primary,
                            colors: colors,
                          ),
                        ),
                      if (config.baseFare > 0 && config.perKmRate > 0)
                        const SizedBox(width: AppSpacing.md),
                      if (config.perKmRate > 0)
                        Expanded(
                          child: _MiniStat(
                            icon: Icons.straighten_rounded,
                            label: "Per KM",
                            value: "₹${config.perKmRate.toStringAsFixed(1)}",
                            color: AppColors.info,
                            colors: colors,
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              // ── Dynamic breakdown items from backend ──
              if (config.breakdown.isNotEmpty) ...[
                _SectionDivider(colors: colors),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        size: 14,
                        color: colors.textTertiary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        "DEDUCTION BREAKDOWN",
                        style: AppTextStyles.overline.copyWith(
                          color: colors.textTertiary,
                          fontSize: 9,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                ...config.breakdown.map((item) => _BreakdownRow(
                      item: item,
                      colors: colors,
                    )),
                const SizedBox(height: AppSpacing.sm),
              ],

              // ── Fallback: show top-level GST/commission if no breakdown list ──
              if (config.breakdown.isEmpty &&
                  (config.platformCommissionAmount > 0 ||
                      config.gstPercent > 0 ||
                      config.tdsPercent > 0)) ...[
                _SectionDivider(colors: colors),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        size: 14,
                        color: colors.textTertiary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        "DEDUCTION BREAKDOWN",
                        style: AppTextStyles.overline.copyWith(
                          color: colors.textTertiary,
                          fontSize: 9,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                if (config.platformCommissionAmount > 0)
                  _FallbackRow(
                    icon: Icons.business_rounded,
                    label: "Platform Commission",
                    value: "₹${config.platformCommissionAmount.toStringAsFixed(0)}",
                    description: "Caby24's service fee per order",
                    color: AppColors.warning,
                    colors: colors,
                  ),
                if (config.gstPercent > 0)
                  _FallbackRow(
                    icon: Icons.account_balance_rounded,
                    label: "GST",
                    value: "${config.gstPercent.toStringAsFixed(1)}%",
                    description: "Government tax on platform commission",
                    color: AppColors.error,
                    colors: colors,
                  ),
                if (config.tdsPercent > 0)
                  _FallbackRow(
                    icon: Icons.assured_workload_rounded,
                    label: "TDS",
                    value: "${config.tdsPercent.toStringAsFixed(1)}%",
                    description: "Tax deducted at source (credited to IT returns)",
                    color: AppColors.purple,
                    colors: colors,
                  ),
                if (config.insuranceLevy > 0)
                  _FallbackRow(
                    icon: Icons.shield_rounded,
                    label: "Insurance Levy",
                    value: "₹${config.insuranceLevy.toStringAsFixed(0)}",
                    description: "Per-trip accident insurance coverage",
                    color: AppColors.info,
                    colors: colors,
                  ),
                const SizedBox(height: AppSpacing.sm),
              ],

              // ── Explainer note ──
              if (config.note != null && config.note!.isNotEmpty) ...[
                _SectionDivider(colors: colors),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          config.note!,
                          style: AppTextStyles.caption.copyWith(
                            color: colors.textTertiary,
                            fontSize: 11,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ── How it works (always shown) ──
              _SectionDivider(colors: colors),
              _HowItWorksSection(config: config, colors: colors),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

// ── Vehicle info helper ──
class _VehicleInfo {
  final String label;
  final IconData icon;
  const _VehicleInfo(this.label, this.icon);
}

_VehicleInfo _getVehicleInfo(String vehicleType) {
  final key = vehicleType.toLowerCase();
  if (key.contains('car') || key.contains('cab') || key.contains('taxi')) {
    return const _VehicleInfo('Car / Cab', Icons.directions_car_rounded);
  }
  if (key.contains('auto') || key.contains('3_wheeler')) {
    return const _VehicleInfo('Auto Rickshaw', Icons.electric_rickshaw_rounded);
  }
  if (key.contains('truck') || key.contains('van') || key.contains('lorry')) {
    return const _VehicleInfo('Truck / Van', Icons.local_shipping_rounded);
  }
  if (key.contains('scooter') || key.contains('scooty')) {
    return const _VehicleInfo('Scooter', Icons.two_wheeler_rounded);
  }
  if (key.contains('cycle') || key.contains('bicycle')) {
    return const _VehicleInfo('Bicycle', Icons.pedal_bike_rounded);
  }
  return const _VehicleInfo('Bike', Icons.electric_moped_rounded);
}

// ── Mini stat widget ──
class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final C colors;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withAlpha(colors.isDark ? 15 : 8),
        borderRadius: AppRadius.lgAll,
        border: Border.all(
          color: color.withAlpha(colors.isDark ? 30 : 18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: colors.textTertiary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.headingSm.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Breakdown row (for dynamic backend items) ──
class _BreakdownRow extends StatelessWidget {
  final EarningConfigItem item;
  final C colors;

  const _BreakdownRow({required this.item, required this.colors});

  @override
  Widget build(BuildContext context) {
    final iconColor = _getItemColor(item.label);
    final iconData = _getItemIcon(item.label);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(colors.isDark ? 25 : 15),
              borderRadius: AppRadius.smAll,
            ),
            child: Icon(iconData, color: iconColor, size: 16),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: AppTextStyles.bodySm.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.description != null && item.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      item.description!,
                      style: AppTextStyles.caption.copyWith(
                        color: colors.textTertiary,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(colors.isDark ? 20 : 12),
              borderRadius: AppRadius.pillAll,
            ),
            child: Text(
              item.displayValue,
              style: AppTextStyles.caption.copyWith(
                color: iconColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getItemColor(String label) {
    final key = label.toLowerCase();
    if (key.contains('gst') || key.contains('tax')) return AppColors.error;
    if (key.contains('tds')) return AppColors.purple;
    if (key.contains('commission') || key.contains('platform')) return AppColors.warning;
    if (key.contains('insurance') || key.contains('shield')) return AppColors.info;
    if (key.contains('incentive') || key.contains('bonus')) return AppColors.success;
    if (key.contains('base') || key.contains('minimum')) return AppColors.primary;
    return AppColors.textSecondary;
  }

  IconData _getItemIcon(String label) {
    final key = label.toLowerCase();
    if (key.contains('gst') || key.contains('tax')) return Icons.account_balance_rounded;
    if (key.contains('tds')) return Icons.assured_workload_rounded;
    if (key.contains('commission') || key.contains('platform')) return Icons.business_rounded;
    if (key.contains('insurance') || key.contains('shield')) return Icons.shield_rounded;
    if (key.contains('incentive') || key.contains('bonus')) return Icons.stars_rounded;
    if (key.contains('base') || key.contains('minimum')) return Icons.flag_rounded;
    if (key.contains('distance') || key.contains('km')) return Icons.straighten_rounded;
    if (key.contains('surge') || key.contains('peak')) return Icons.trending_up_rounded;
    return Icons.receipt_rounded;
  }
}

// ── Fallback row (for top-level fields) ──
class _FallbackRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String description;
  final Color color;
  final C colors;

  const _FallbackRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.description,
    required this.color,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withAlpha(colors.isDark ? 25 : 15),
              borderRadius: AppRadius.smAll,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: AppSpacing.md),
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
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    description,
                    style: AppTextStyles.caption.copyWith(
                      color: colors.textTertiary,
                      fontSize: 10.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withAlpha(colors.isDark ? 20 : 12),
              borderRadius: AppRadius.pillAll,
            ),
            child: Text(
              value,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section divider ──
class _SectionDivider extends StatelessWidget {
  final C colors;
  const _SectionDivider({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: colors.divider.withAlpha(colors.isDark ? 40 : 80),
      height: 1,
      indent: AppSpacing.xl,
      endIndent: AppSpacing.xl,
    );
  }
}

// ── "How it works" explainer section ──
class _HowItWorksSection extends StatelessWidget {
  final EarningConfig config;
  final C colors;

  const _HowItWorksSection({required this.config, required this.colors});

  @override
  Widget build(BuildContext context) {
    // Build the flow steps based on available config
    final steps = <_StepData>[];
    
    steps.add(_StepData(
      '1',
      'Customer pays total fare',
      'Includes base fare + distance charge',
      Icons.payments_rounded,
      AppColors.success,
    ));

    if (config.platformCommissionAmount > 0 || config.breakdown.isNotEmpty) {
      steps.add(_StepData(
        '2',
        'Platform deducts commission',
        config.platformCommissionAmount > 0
            ? '₹${config.platformCommissionAmount.toStringAsFixed(0)} flat fee per order'
            : 'As per your vehicle category',
        Icons.business_rounded,
        AppColors.warning,
      ));
    }

    if (config.gstPercent > 0 ||
        config.breakdown.any((i) => i.label.toLowerCase().contains('gst'))) {
      final gstVal = config.gstPercent > 0
          ? '${config.gstPercent.toStringAsFixed(0)}% GST on commission'
          : 'Applied on platform commission';
      steps.add(_StepData(
        '${steps.length + 1}',
        'GST is applied',
        gstVal,
        Icons.account_balance_rounded,
        AppColors.error,
      ));
    }

    steps.add(_StepData(
      '${steps.length + 1}',
      'You receive net earnings',
      'Total fare minus all deductions',
      Icons.wallet_rounded,
      AppColors.primary,
    ));

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 14,
                color: AppColors.starYellow,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                "HOW IT WORKS",
                style: AppTextStyles.overline.copyWith(
                  color: colors.textTertiary,
                  fontSize: 9,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...List.generate(steps.length, (index) {
            final step = steps[index];
            final isLast = index == steps.length - 1;
            return _StepWidget(
              step: step,
              isLast: isLast,
              colors: colors,
            );
          }),
        ],
      ),
    );
  }
}

class _StepData {
  final String number;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StepData(this.number, this.title, this.subtitle, this.icon, this.color);
}

class _StepWidget extends StatelessWidget {
  final _StepData step;
  final bool isLast;
  final C colors;

  const _StepWidget({
    required this.step,
    required this.isLast,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot + line
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: step.color.withAlpha(colors.isDark ? 30 : 18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: step.color.withAlpha(colors.isDark ? 60 : 40),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      step.number,
                      style: AppTextStyles.caption.copyWith(
                        color: step.color,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: colors.divider.withAlpha(colors.isDark ? 30 : 50),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: AppTextStyles.bodySm.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: colors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
