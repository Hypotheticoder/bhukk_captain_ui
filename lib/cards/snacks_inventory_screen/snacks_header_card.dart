import 'package:bhukkdelivery/notifiers/snacks_inventory_screen/snacks_state.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SnacksHeaderCard extends StatelessWidget {
  final SnacksState state;

  const SnacksHeaderCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            Color.lerp(AppColors.primary, Colors.black, 0.35)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.xxlAll,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(colors.isDark ? 70 : 100),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "My Inventory",
                style: AppTextStyles.bodySm.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: state.totalProducts.toDouble()),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Text(
                "${value.toInt()} Products",
                style: AppTextStyles.headingMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),

          // Stats row
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(40),
              borderRadius: AppRadius.lgAll,
              border: Border.all(
                color: Colors.white.withAlpha(15),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                // Total Units
                Expanded(
                  child: _StatItem(
                    icon: Icons.all_inbox_rounded,
                    iconColor: AppColors.info,
                    label: "Units",
                    value: "${state.totalUnits}",
                  ),
                ),
                Container(
                  width: 0.5,
                  height: 30,
                  color: Colors.white.withAlpha(20),
                ),
                // Total Value
                Expanded(
                  child: _StatItem(
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: AppColors.success,
                    label: "Value",
                    value: "₹${state.totalValue.toStringAsFixed(0)}",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.overline.copyWith(
                fontSize: 9,
                color: Colors.white54,
                letterSpacing: 0.8,
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(
                begin: 0,
                end: double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), '')) ??
                    0,
              ),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, animValue, _) {
                final display = value.startsWith('₹')
                    ? "₹${animValue.toInt()}"
                    : "${animValue.toInt()}";
                return Text(
                  display,
                  style: AppTextStyles.label.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.w800,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
