import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';

class OrderActionButtons extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final bool hasMoreOrders;

  const OrderActionButtons({
    super.key,
    required this.onAccept,
    required this.onReject,
    this.hasMoreOrders = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: onReject,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 58,
              decoration: BoxDecoration(
                borderRadius: AppRadius.pillAll,
                border: Border.all(
                  color: AppColors.secondary.withAlpha(51),
                ),
                color: colors.isDark ? colors.surfaceElevated : null,
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasMoreOrders
                          ? Icons.skip_next_rounded
                          : Icons.close_rounded,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      hasMoreOrders ? "Skip" : "Reject",
                      style: AppTextStyles.buttonText.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: onAccept,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 58,
              decoration: AppButtonStyles.primaryButton,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 20,
                      color: AppColors.textOnPrimary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      "Accept Order",
                      style: AppTextStyles.buttonText.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
