import 'dart:io';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:bhukkdelivery/widgets/document_viewer_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class DocumentUploadCard extends StatelessWidget {
  final String? profilePhotoPath;
  final String? drivingLicensePath;
  final String? rcBookPath;
  final String? insurancePath;
  final String? panCardPath;
  final String? aadharCardPath;
  final int uploadedCount;
  final String? errorMessage;
  final void Function(String docType, String path) onDocumentPicked;
  final void Function(String docType) onDocumentRemoved;

  const DocumentUploadCard({
    super.key,
    this.profilePhotoPath,
    this.drivingLicensePath,
    this.rcBookPath,
    this.insurancePath,
    this.panCardPath,
    this.aadharCardPath,
    this.uploadedCount = 0,
    this.errorMessage,
    required this.onDocumentPicked,
    required this.onDocumentRemoved,
  });

  Future<void> _pickImage(BuildContext context, String docType) async {
    HapticFeedback.selectionClick();
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );
    if (image != null) {
      onDocumentPicked(docType, image.path);
    }
  }

  Future<void> _pickFile(BuildContext context, String docType) async {
    HapticFeedback.selectionClick();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      onDocumentPicked(docType, result.files.single.path!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress indicator
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withAlpha(colors.isDark ? 25 : 12),
                AppColors.primaryAccent.withAlpha(colors.isDark ? 15 : 8),
              ],
            ),
            borderRadius: AppRadius.lgAll,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "$uploadedCount/6",
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Documents Uploaded",
                      style: AppTextStyles.bodySm.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Profile photo & DL are required",
                      style: AppTextStyles.caption.copyWith(
                        color: colors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Profile Photo (Image picker)
        _DocTile(
          title: "Profile Photo",
          subtitle: "Clear face photo",
          icon: Icons.camera_alt_rounded,
          filePath: profilePhotoPath,
          isRequired: true,
          isImage: true,
          onPick: () => _pickImage(context, 'profile'),
          onRemove: () => onDocumentRemoved('profile'),
          colors: colors,
        ),
        const SizedBox(height: AppSpacing.md),

        // Driving License
        _DocTile(
          title: "Driving License",
          subtitle: "Upload front side",
          icon: Icons.credit_card_rounded,
          filePath: drivingLicensePath,
          isRequired: true,
          onPick: () => _pickFile(context, 'dl'),
          onRemove: () => onDocumentRemoved('dl'),
          colors: colors,
        ),
        const SizedBox(height: AppSpacing.md),

        // RC Book
        _DocTile(
          title: "RC Book",
          subtitle: "Vehicle registration",
          icon: Icons.description_rounded,
          filePath: rcBookPath,
          onPick: () => _pickFile(context, 'rc'),
          onRemove: () => onDocumentRemoved('rc'),
          colors: colors,
        ),
        const SizedBox(height: AppSpacing.md),

        // Insurance
        _DocTile(
          title: "Vehicle Insurance",
          subtitle: "Valid insurance copy",
          icon: Icons.security_rounded,
          filePath: insurancePath,
          onPick: () => _pickFile(context, 'insurance'),
          onRemove: () => onDocumentRemoved('insurance'),
          colors: colors,
        ),
        const SizedBox(height: AppSpacing.md),

        // PAN Card
        _DocTile(
          title: "PAN Card",
          subtitle: "For tax verification",
          icon: Icons.badge_rounded,
          filePath: panCardPath,
          onPick: () => _pickFile(context, 'pan'),
          onRemove: () => onDocumentRemoved('pan'),
          colors: colors,
        ),
        const SizedBox(height: AppSpacing.md),

        // Aadhar Card
        _DocTile(
          title: "Aadhar Card",
          subtitle: "Identity verification",
          icon: Icons.fingerprint_rounded,
          filePath: aadharCardPath,
          onPick: () => _pickFile(context, 'aadhar'),
          onRemove: () => onDocumentRemoved('aadhar'),
          colors: colors,
        ),

        if (errorMessage != null && errorMessage!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.error.withAlpha(12),
              borderRadius: AppRadius.mdAll,
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.error, size: 16),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _DocTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? filePath;
  final bool isRequired;
  final bool isImage;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  final C colors;

  const _DocTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.filePath,
    this.isRequired = false,
    this.isImage = false,
    required this.onPick,
    required this.onRemove,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final isUploaded = filePath != null;

    return GestureDetector(
      onTap: isUploaded
          ? () {
              HapticFeedback.lightImpact();
              showDialog(
                context: context,
                builder: (ctx) => DocumentViewerDialog(
                  title: title,
                  path: filePath!,
                  onReplace: onPick,
                ),
              );
            }
          : onPick,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isUploaded
              ? AppColors.success.withAlpha(colors.isDark ? 15 : 8)
              : colors.surfaceElevated,
          borderRadius: AppRadius.lgAll,
          border: Border.all(
            color: isUploaded
                ? AppColors.success.withAlpha(60)
                : colors.divider,
            width: isUploaded ? 1 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.cardShadow(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail or icon
            if (isImage && isUploaded)
              ClipRRect(
                borderRadius: AppRadius.mdAll,
                child: Image.file(
                  File(filePath!),
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isUploaded
                      ? AppColors.success.withAlpha(25)
                      : AppColors.primary.withAlpha(colors.isDark ? 20 : 10),
                  borderRadius: AppRadius.mdAll,
                ),
                child: Icon(
                  isUploaded ? Icons.check_rounded : icon,
                  color: isUploaded ? AppColors.success : AppColors.primary,
                  size: 22,
                ),
              ),
            const SizedBox(width: AppSpacing.md),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodySm.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (isRequired) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          "*",
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isUploaded ? "Uploaded ✓" : subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: isUploaded
                          ? AppColors.success
                          : colors.textTertiary,
                      fontWeight:
                          isUploaded ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Action
            if (isUploaded)
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppColors.error,
                    size: 16,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(15),
                  borderRadius: AppRadius.pillAll,
                ),
                child: Text(
                  "Upload",
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
