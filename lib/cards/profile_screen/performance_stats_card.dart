import 'package:bhukkdelivery/providers/profile/profile_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';

class PerformanceStatsCard extends StatelessWidget {
  final UserProfile profile;

  const PerformanceStatsCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl,
        horizontal: AppSpacing.sm + 2,
      ),
      decoration: colors.card,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem("Rating", "${profile.rating} ★", AppColors.starYellow, colors),
          Container(height: 40, width: 1, color: colors.divider),
          _buildStatItem("Deliveries", "${profile.totalDeliveries}", AppColors.primary, colors),
          Container(height: 40, width: 1, color: colors.divider),
          _buildStatItem("Tips", "₹ 2.5k", AppColors.success, colors),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor, C colors) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.statValue.copyWith(color: valueColor),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: colors.textTertiary),
        ),
      ],
    );
  }
}
