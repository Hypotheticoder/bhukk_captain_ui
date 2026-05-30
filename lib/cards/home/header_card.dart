import 'package:bhukkdelivery/cards/profile_screen/profile_header_card.dart';
import 'package:bhukkdelivery/providers/theme/theme_provider.dart';
import 'package:bhukkdelivery/providers/home/master_dashboard_provider.dart';
import 'package:bhukkdelivery/providers/profile/profile_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HeaderCard extends ConsumerWidget {
  const HeaderCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = C.of(context);
    final isOnline = ref.watch(masterDashboardProvider).isAnyServiceOnline;
    final profile = ref.watch(profileProvider);

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left — Brand logo + status
          Expanded(
            child: Row(
              children: [
                // Brand wordmark — sole brand identifier
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/icons/brand.png',
                        height: 40,
                        fit: BoxFit.contain,
                        alignment: Alignment.centerLeft,
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
                                  color: isOnline
                                      ? AppColors.successLight.withAlpha(
                                          colors.isDark ? 40 : 255,
                                        )
                                      : colors.divider.withAlpha(
                                          colors.isDark ? 40 : 255,
                                        ),
                                  borderRadius: AppRadius.pillAll,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isOnline
                                            ? AppColors.success
                                            : colors.textTertiary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isOnline
                                          ? "Ready for deliveries"
                                          : "You are offline",
                                      style: AppTextStyles.caption.copyWith(
                                        color: isOnline
                                            ? AppColors.success
                                            : colors.textTertiary,
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
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Right — Dark mode toggle + Notification + Avatar
          Row(
            children: [
              // Dark mode toggle
              GestureDetector(
                onTap: () {
                  ref.read(themeModeProvider.notifier).toggle();
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm + 2),
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: AppRadius.mdAll,
                    border: Border.all(
                      color: colors.divider.withAlpha(80),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.cardShadow(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    colors.isDark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    color: colors.textSecondary,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Notification bell hidden for now
              // Profile avatar
              GestureDetector(
                onTap: () => context.go('/profile'),
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondaryCyan],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: colors.surface,
                    backgroundImage: (profile?.profilePhotoPath != null &&
                            profile!.profilePhotoPath!.isNotEmpty)
                        ? ProfileHeaderCard.resolveProfileImage(
                            profile.profilePhotoPath!)
                        : null,
                    child: (profile?.profilePhotoPath == null ||
                            profile!.profilePhotoPath!.isEmpty)
                        ? Icon(
                            Icons.person_rounded,
                            color: AppColors.secondaryCyan,
                            size: 22,
                          )
                        : null,
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
