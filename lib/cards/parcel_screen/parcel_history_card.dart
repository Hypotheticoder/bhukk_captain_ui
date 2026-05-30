import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ParcelHistoryCard extends StatelessWidget {
  final Map<String, String> ride;

  const ParcelHistoryCard({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    final status = ride['status'] ?? 'Completed';
    final isCompleted = status.toLowerCase() == 'completed';

    return Container(
      decoration: colors.card,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.parcel.withAlpha(25),
              borderRadius: AppRadius.mdAll,
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: AppColors.parcel,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ride['title'] ?? 'Parcel #',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  ride['date'] ?? '',
                  style: AppTextStyles.caption.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(
                      ride['distance'] ?? '-',
                      style: AppTextStyles.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      ride['duration'] ?? '-',
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
                ride['fare'] ?? '-',
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
