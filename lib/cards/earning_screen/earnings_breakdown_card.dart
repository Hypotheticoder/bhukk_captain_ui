import 'package:bhukkdelivery/providers/earnings/earnings_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EarningsBreakdownCard extends ConsumerWidget {
  const EarningsBreakdownCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = C.of(context);
    final state = ref.watch(earningsProvider);

    // Accounting buckets with live backend data
    final items = [
      _BreakdownItem(
        'Today\'s Earnings',
        state.todayEarnings,
        Icons.stars_rounded,
        AppColors.primary,
        "Your net payout for completed jobs today",
      ),
      _BreakdownItem(
        'Ride Earnings',
        state.rideEarnings,
        Icons.directions_car_rounded,
        AppColors.primary,
        "Total earnings from passenger rides",
      ),
      _BreakdownItem(
        'Parcel Earnings',
        state.parcelEarnings,
        Icons.inventory_2_rounded,
        AppColors.success,
        "Total earnings from deliveries",
      ),
      _BreakdownItem(
        'Cash in Pocket',
        state.cashInHand,
        Icons.payments_rounded,
        const Color(0xFFF59E0B),
        "Physical COD cash you collected today",
      ),
      _BreakdownItem(
        'Commission Owed',
        state.commissionOwed,
        Icons.money_off_rounded,
        AppColors.error,
        "Platform fees you hold from COD orders",
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Main breakdown cards ──
        ...items.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            decoration: colors.card,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: item.color.withAlpha(colors.isDark ? 35 : 18),
                    borderRadius: AppRadius.smAll,
                  ),
                  child: Icon(item.icon, color: item.color, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: AppTextStyles.caption.copyWith(
                          color: colors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "₹ ${_formatAmount(item.amount)}",
                  style: AppTextStyles.bodyLg.copyWith(
                    fontWeight: FontWeight.w800,
                    color: item.color,
                  ),
                ),
              ],
            ),
          );
        }),

        // ── COD vs Online Payment Mode Split ──
        if (state.codEarnings > 0 || state.onlineEarnings > 0) ...[
          const SizedBox(height: AppSpacing.sm),
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
                  child: _PaymentSummaryTile(
                    icon: Icons.payments_rounded,
                    label: "Cash (COD)",
                    amount: state.codEarnings,
                    color: const Color(0xFFF59E0B),
                    colors: colors,
                  ),
                ),
              if (state.codEarnings > 0 && state.onlineEarnings > 0)
                const SizedBox(width: AppSpacing.md),
              if (state.onlineEarnings > 0)
                Expanded(
                  child: _PaymentSummaryTile(
                    icon: Icons.credit_card_rounded,
                    label: "Online",
                    amount: state.onlineEarnings,
                    color: const Color(0xFF6366F1),
                    colors: colors,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }

  String _formatAmount(double val) {
    if (val >= 1000) {
      final k = val / 1000;
      final remainder = val % 1000;
      if (remainder == 0) return "${k.toStringAsFixed(0)},000";
      return "${k.floor()},${remainder.toStringAsFixed(0).padLeft(3, '0')}";
    }
    return val.toStringAsFixed(0);
  }
}

class _BreakdownItem {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _BreakdownItem(
      this.label, this.amount, this.icon, this.color, this.subtitle);
}

class _PaymentSummaryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;
  final C colors;

  const _PaymentSummaryTile({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withAlpha(colors.isDark ? 18 : 10),
        borderRadius: AppRadius.lgAll,
        border: Border.all(
          color: color.withAlpha(colors.isDark ? 35 : 20),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
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
            "₹ ${amount.toStringAsFixed(0)}",
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
