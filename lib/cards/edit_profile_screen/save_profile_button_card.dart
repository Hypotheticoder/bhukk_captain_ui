import 'package:bhukkdelivery/providers/edit_profile/edit_profile_provider.dart';
import 'package:bhukkdelivery/providers/profile/profile_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SaveProfileButtonCard extends ConsumerWidget {
  const SaveProfileButtonCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = C.of(context);
    final editState = ref.watch(editProfileProvider);

    return Column(
      children: [
        GestureDetector(
          onTap: editState.isSaving
              ? null
              : () async {
                  await ref
                      .read(editProfileProvider.notifier)
                      .saveProfile();

                  final state = ref.read(editProfileProvider);
                  // Push edits to global profile state
                  ref.read(profileProvider.notifier).updateProfile(
                        name: state.name,
                        phone: state.phone,
                        email: state.email,
                        vehicleType: state.vehicleType,
                        vehicleNumber: state.vehicleNumber,
                      );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Profile updated successfully!"),
                      ),
                    );
                    context.pop();
                  }
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg + 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: editState.isSaving
                    ? [
                        AppColors.primary.withAlpha(150),
                        AppColors.primaryAccent.withAlpha(150),
                      ]
                    : [AppColors.primary, AppColors.primaryAccent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: AppRadius.pillAll,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(editState.isSaving ? 40 : 100),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: editState.isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          "Save Changes",
                          style: AppTextStyles.buttonText.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Cancel button
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 2),
            decoration: BoxDecoration(
              borderRadius: AppRadius.pillAll,
              border: Border.all(
                color: colors.blush.withAlpha(colors.isDark ? 60 : 150),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                "Cancel",
                style: AppTextStyles.buttonText.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
