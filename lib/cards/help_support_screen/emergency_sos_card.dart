import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';

class EmergencySosCard extends StatefulWidget {
  const EmergencySosCard({super.key});

  @override
  State<EmergencySosCard> createState() => _EmergencySosCardState();
}

class _EmergencySosCardState extends State<EmergencySosCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: AppRadius.xlAll,
        border: Border.all(
          color: AppColors.error.withAlpha(colors.isDark ? 60 : 40),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withAlpha(colors.isDark ? 20 : 12),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Pulsing SOS icon
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.error.withAlpha(colors.isDark ? 60 : 35),
                    AppColors.error.withAlpha(colors.isDark ? 30 : 15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.mdAll,
              ),
              child: const Icon(
                Icons.sos_rounded,
                color: AppColors.error,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Emergency SOS",
                  style: AppTextStyles.bodyLg.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  "Feel unsafe? Tap to immediately alert our safety team.",
                  style: AppTextStyles.caption.copyWith(
                    color: colors.textTertiary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Arrow
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.error.withAlpha(colors.isDark ? 40 : 20),
              borderRadius: AppRadius.smAll,
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.error,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
