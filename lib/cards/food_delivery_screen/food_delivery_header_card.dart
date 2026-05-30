import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';

class FoodDeliveryHeaderCard extends StatelessWidget {
  const FoodDeliveryHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutBack,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm + 2),
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: AppRadius.mdAll,
                boxShadow: [
                  BoxShadow(
                    color: colors.cardShadow(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: colors.textSecondary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Food Delivery 🍽️",
                  style: AppTextStyles.headingLg.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm + 2,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.foodDelivery.withAlpha(
                              colors.isDark ? 40 : 22,
                            ),
                            borderRadius: AppRadius.pillAll,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.foodDelivery,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Restaurant Orders",
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.foodDelivery,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  height: 3,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.pillAll,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.foodDelivery,
                        AppColors.foodDelivery.withAlpha(120),
                      ],
                    ),
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
