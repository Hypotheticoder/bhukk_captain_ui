import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';

class FoodHistoryCard extends StatelessWidget {
  final Map<String, String> order;

  const FoodHistoryCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    final status = order['status'] ?? 'Completed';
    final isCompleted = status.toLowerCase() == 'completed';

    return Container(
      decoration: colors.card,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.foodDelivery.withAlpha(25),
              borderRadius: AppRadius.mdAll,
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: AppColors.foodDelivery,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['title'] ?? 'Food Order',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  order['date'] ?? '',
                  style: AppTextStyles.caption.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(
                      order['distance'] ?? '-',
                      style: AppTextStyles.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      order['duration'] ?? '-',
                      style: AppTextStyles.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                order['fare'] ?? '-',
                style: AppTextStyles.bodyMd.copyWith(
                  color: isCompleted ? AppColors.primary : AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.successLight.withAlpha(30)
                      : AppColors.errorLight.withAlpha(30),
                  borderRadius: AppRadius.pillAll,
                ),
                child: Text(
                  status,
                  style: AppTextStyles.caption.copyWith(
                    color: isCompleted ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
