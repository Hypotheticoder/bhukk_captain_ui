import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:bhukkdelivery/providers/home/master_dashboard_provider.dart';
import 'package:bhukkdelivery/providers/profile/profile_provider.dart';
import 'package:bhukkdelivery/providers/login/login_provider.dart';
import 'package:bhukkdelivery/services/api/auth_service.dart';
import 'package:bhukkdelivery/services/api/driver_service.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileActionsCard extends ConsumerWidget {
  const ProfileActionsCard({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    final colors = C.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
        title: Text(
          "Logout",
          style: AppTextStyles.headingSm.copyWith(color: colors.textPrimary),
        ),
        content: Text(
          "Are you sure you want to logout? You'll need to sign in again to accept orders.",
          style: AppTextStyles.bodyMd.copyWith(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              "Cancel",
              style: AppTextStyles.buttonText.copyWith(color: colors.textTertiary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              "Logout",
              style: AppTextStyles.buttonText.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // 1. ✅ ADDED AWAIT: Wait for the backend to clear the FCM token!
    try {
      await DriverService.logoutDriver();
      debugPrint('[ProfileActionsCard] Backend logout successful.');
    } catch (e) {
      debugPrint('[ProfileActionsCard] Backend logout failed (Fallback initiated): $e');
      // We continue with the local logout even if the server fails, 
      // so the driver isn't permanently trapped on the app.
    }

    // 2. Sign out of Firebase first to cleanly trigger global auth state changes
    await AuthService.signOut();

    // 3. Clear all user-specific state locally
    ref.invalidate(profileProvider);
    ref.invalidate(masterDashboardProvider);
    ref.invalidate(activeDeliveryProvider);
    ref.invalidate(loginProvider); // 💥 Reset login/OTP state back to phone input step!

    // 4. Navigate to login screen instantly
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = C.of(context);

    return Column(
      children: [
        _buildActionButton(
            "Help & Support", Icons.headset_mic_outlined, AppColors.success, () => context.push('/profile/help_support'), colors),
        const SizedBox(height: AppSpacing.xxl),
        TextButton(
          onPressed: () => _handleLogout(context, ref),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout, color: AppColors.error, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                "Logout",
                style: AppTextStyles.buttonText.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color iconColor, VoidCallback onTap, C colors) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.lgAll,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        decoration: colors.actionListItem,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: colors.iconContainer(color: iconColor),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMd.copyWith(
                  color: colors.textPrimary.withAlpha(222),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
