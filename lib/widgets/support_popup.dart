import 'package:bhukkdelivery/providers/settings/settings_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

// ──────────────────────────────────────────────────────────────
//  Call-Support Popup  —  reusable across all screens
//  Uses the dynamic `/settings/support_phone` provider so the
//  number can be changed from the admin panel without an update.
// ──────────────────────────────────────────────────────────────

/// Shows a premium glass-card bottom-sheet for calling support.
///
/// Usage from any ConsumerWidget / ConsumerStatefulWidget:
/// ```dart
/// showSupportPopup(context, ref);
/// ```
void showSupportPopup(BuildContext context) {
  HapticFeedback.mediumImpact();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withAlpha(120),
    builder: (_) => const _SupportSheet(),
  );
}

class _SupportSheet extends ConsumerWidget {
  const _SupportSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = C.of(context);
    final phoneAsync = ref.watch(supportPhoneProvider);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: AppRadius.xxlAll,
        border: Border.all(
          color: AppColors.primary.withAlpha(colors.isDark ? 50 : 35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(colors.isDark ? 25 : 15),
            blurRadius: 30,
            offset: const Offset(0, -8),
            spreadRadius: 3,
          ),
          BoxShadow(
            color: colors.cardShadow(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle bar ──
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.divider,
                borderRadius: AppRadius.pillAll,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Icon ──
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.darkCyan, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(80),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.headset_mic_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Title ──
            Text(
              'Need Help?',
              style: AppTextStyles.headingMd.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Subtitle ──
            Text(
              'Our support team is available 24/7 to\nassist you with any delivery issues.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySm.copyWith(
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Phone number chip ──
            phoneAsync.when(
              data: (phone) {
                final displayPhone = phone ?? 'Unavailable';
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.lg,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(colors.isDark ? 20 : 12),
                    borderRadius: AppRadius.lgAll,
                    border: Border.all(
                      color: AppColors.primary.withAlpha(colors.isDark ? 40 : 25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          displayPhone,
                          style: AppTextStyles.bodyLg.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      if (phone != null)
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: phone));
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Number copied!'),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.mdAll,
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(
                                  colors.isDark ? 30 : 18),
                              borderRadius: AppRadius.smAll,
                            ),
                            child: const Icon(
                              Icons.copy_rounded,
                              color: AppColors.primary,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
              loading: () => Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: colors.blush.withAlpha(colors.isDark ? 30 : 60),
                  borderRadius: AppRadius.lgAll,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              error: (_, _) => Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(15),
                  borderRadius: AppRadius.lgAll,
                  border: Border.all(
                    color: AppColors.error.withAlpha(40),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Could not load support number.\nPlease try again later.',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.error,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Call button ──
            phoneAsync.when(
              data: (phone) {
                final hasPhone = phone != null && phone.isNotEmpty;
                return GestureDetector(
                  onTap: hasPhone
                      ? () async {
                          HapticFeedback.mediumImpact();
                          final uri = Uri.parse('tel:$phone');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        }
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: hasPhone
                          ? const LinearGradient(
                              colors: [AppColors.darkCyan, AppColors.primary],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                          : null,
                      color: hasPhone ? null : colors.blush,
                      borderRadius: AppRadius.pillAll,
                      boxShadow: hasPhone
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(100),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.call_rounded,
                          color: hasPhone ? Colors.white : colors.textTertiary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Call Support',
                          style: AppTextStyles.buttonText.copyWith(
                            color:
                                hasPhone ? Colors.white : colors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => GestureDetector(
                onTap: () => ref.invalidate(supportPhoneProvider),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: AppRadius.pillAll,
                    border: Border.all(color: AppColors.primary.withAlpha(60)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.refresh_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Retry',
                        style: AppTextStyles.buttonText.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Info chips ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _InfoChip(
                  icon: Icons.schedule_rounded,
                  label: '24/7 Available',
                  colors: colors,
                ),
                const SizedBox(width: AppSpacing.md),
                _InfoChip(
                  icon: Icons.verified_rounded,
                  label: 'Official Support',
                  colors: colors,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small info chip ──────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final C colors;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: colors.blush.withAlpha(colors.isDark ? 30 : 77),
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  Floating Support FAB — place in a Stack for overlay usage
// ──────────────────────────────────────────────────────────────
class SupportFab extends ConsumerWidget {
  const SupportFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = C.of(context);

    return GestureDetector(
      onTap: () => showSupportPopup(context),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.darkCyan, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(80),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: colors.cardShadow(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.headset_mic_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
