import 'dart:io';
import 'package:bhukkdelivery/providers/profile/profile_provider.dart';
import 'package:bhukkdelivery/services/api/api_config.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ProfileHeaderCard extends ConsumerWidget {
  final UserProfile profile;

  const ProfileHeaderCard({super.key, required this.profile});

  /// Resolves a profile photo path to the correct ImageProvider.
  /// Server paths (starting with /uploads/) → NetworkImage with full URL.
  /// Local file paths → FileImage.
  static ImageProvider resolveProfileImage(String path) {
    if (path.startsWith('/uploads/') || path.startsWith('http')) {
      final url = path.startsWith('http') ? path : '${ApiConfig.baseUrl}$path';
      debugPrint('[ProfileHeader] Loading image from: $url');
      return NetworkImage(url);
    }
    debugPrint('[ProfileHeader] Loading local file: $path');
    return FileImage(File(path));
  }

  Future<void> _showPhotoOptions(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    final colors = C.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: AppRadius.pillAll,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  "Update Profile Photo",
                  style: AppTextStyles.headingSm.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Row(
                  children: [
                    Expanded(
                      child: _PhotoOption(
                        icon: Icons.camera_alt_rounded,
                        label: "Camera",
                        color: AppColors.primary,
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickImage(context, ref, ImageSource.camera);
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: _PhotoOption(
                        icon: Icons.photo_library_rounded,
                        label: "Gallery",
                        color: AppColors.info,
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickImage(context, ref, ImageSource.gallery);
                        },
                      ),
                    ),
                    if (profile.profilePhotoPath != null) ...[
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: _PhotoOption(
                          icon: Icons.delete_outline_rounded,
                          label: "Remove",
                          color: AppColors.error,
                          onTap: () {
                            Navigator.pop(ctx);
                            ref
                                .read(profileProvider.notifier)
                                .removeDocument('profile');
                          },
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (image != null) {
      ref.read(profileProvider.notifier).setProfilePhoto(image.path);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: AppDecorations.gradientCard,
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () => _showPhotoOptions(context, ref),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(51),
                  ),
                  child:
                      profile.profilePhotoPath != null &&
                          profile.profilePhotoPath!.isNotEmpty
                      ? CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          backgroundImage: resolveProfileImage(
                            profile.profilePhotoPath!,
                          ),
                          onBackgroundImageError: (error, stackTrace) {
                            debugPrint(
                              '[ProfileHeader] ❌ Failed to load image: ${profile.profilePhotoPath}',
                            );
                          },
                          child: null, // image fills the avatar
                        )
                      : const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: AppColors.textTertiary,
                          ),
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showPhotoOptions(context, ref),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(100),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            profile.name,
            style: AppTextStyles.headingMd.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            "Delivery Partner • Since ${profile.joinDate}",
            style: AppTextStyles.bodySm.copyWith(
              color: Colors.white.withAlpha(230),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PhotoOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        decoration: BoxDecoration(
          color: color.withAlpha(colors.isDark ? 20 : 12),
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: color.withAlpha(40), width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
