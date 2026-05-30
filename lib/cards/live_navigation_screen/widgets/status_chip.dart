import 'package:flutter/material.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  final bool isLoading;

  const StatusChip({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceElevated.withAlpha(220),
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: isLoading ? AppColors.primary : AppColors.info,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            isLoading ? 'Loading route...' : 'Getting GPS...',
            style: AppTextStyles.caption.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
