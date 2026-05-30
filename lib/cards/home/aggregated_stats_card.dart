import 'package:bhukkdelivery/providers/home/master_dashboard_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Displays aggregate totals (orders, earnings, completion rate)
/// across all delivery services.
class AggregatedStatsCard extends ConsumerWidget {
  const AggregatedStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = C.of(context);
    final state = ref.watch(masterDashboardProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: colors.elevatedCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(colors.isDark ? 35 : 20),
                  borderRadius: AppRadius.smAll,
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                "Today's Overview",
                style: AppTextStyles.label.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              // ── Total Orders ──
              Expanded(
                child: _StatBlock(
                  label: "Orders",
                  value: "${state.totalOrders}",
                  icon: Icons.receipt_long_rounded,
                  color: AppColors.info,
                  colors: colors,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: colors.divider,
              ),
              // ── Total Earnings ──
              Expanded(
                child: _StatBlock(
                  label: "Earnings",
                  value: "₹${state.totalEarnings.toStringAsFixed(0)}",
                  icon: Icons.account_balance_wallet_rounded,
                  color: AppColors.success,
                  colors: colors,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: colors.divider,
              ),
              // ── Completion Rate ──
              Expanded(
                child: _CompletionBlock(
                  rate: state.completionRate,
                  colors: colors,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final C colors;

  const _StatBlock({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        return Opacity(
          opacity: val.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - val)),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.statValue.copyWith(
              color: colors.textPrimary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: colors.textTertiary,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionBlock extends StatelessWidget {
  final double rate;
  final C colors;

  const _CompletionBlock({required this.rate, required this.colors});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: rate),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, val, _) {
        return Column(
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: val,
                    strokeWidth: 3.5,
                    backgroundColor: colors.divider,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    strokeCap: StrokeCap.round,
                  ),
                  Text(
                    "${(val * 100).toInt()}%",
                    style: AppTextStyles.caption.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              "Complete",
              style: AppTextStyles.caption.copyWith(
                color: colors.textTertiary,
                fontSize: 10.5,
              ),
            ),
          ],
        );
      },
    );
  }
}
