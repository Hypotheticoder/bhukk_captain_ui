import 'package:flutter/material.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';

class LiveBadge extends StatelessWidget {
  final Animation<double> pulseAnim;

  const LiveBadge({super.key, required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.error.withAlpha(colors.isDark ? 200 : 255),
            borderRadius: AppRadius.pillAll,
            boxShadow: [
              BoxShadow(
                color: AppColors.error.withAlpha(
                  (150 * pulseAnim.value).toInt(),
                ),
                blurRadius: 10 * pulseAnim.value,
                spreadRadius: 2 * pulseAnim.value,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                "LIVE",
                style: AppTextStyles.label.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
