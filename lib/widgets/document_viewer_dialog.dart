import 'dart:io';
import 'package:bhukkdelivery/services/api/api_config.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DocumentViewerDialog extends StatelessWidget {
  final String title;
  final String path;
  final VoidCallback? onReplace;

  const DocumentViewerDialog({
    super.key,
    required this.title,
    required this.path,
    this.onReplace,
  });

  bool get _isImage {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp');
  }

  ImageProvider _resolveImage() {
    if (path.startsWith('/uploads/') || path.startsWith('http')) {
      final url = path.startsWith('http') ? path : '${ApiConfig.baseUrl}$path';
      return NetworkImage(url);
    }
    return FileImage(File(path));
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    final isDark = colors.isDark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surfaceElevated.withAlpha(isDark ? 230 : 245),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withAlpha(isDark ? 30 : 100),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 100 : 30),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colors.divider.withAlpha(30),
                    width: 0.5,
                  ),
                  color: colors.divider.withAlpha(10),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(isDark ? 30 : 15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyLg.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: colors.textTertiary,
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),

              // Content Area
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                    minHeight: 250,
                  ),
                  color: isDark
                      ? Colors.black.withAlpha(40)
                      : Colors.white.withAlpha(80),
                  child: Center(
                    child: _isImage
                        ? InteractiveViewer(
                            panEnabled: true,
                            minScale: 0.5,
                            maxScale: 4.0,
                            child: Image(
                              image: _resolveImage(),
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: AppColors.primary,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.broken_image_outlined,
                                      color: AppColors.error,
                                      size: 48,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Text(
                                      "Unable to load image",
                                      style: AppTextStyles.bodyMd.copyWith(
                                        color: colors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      path.split('/').last,
                                      style: AppTextStyles.caption.copyWith(
                                        color: colors.textTertiary,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.xxl),
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withAlpha(isDark ? 20 : 10),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.picture_as_pdf_rounded,
                                  color: AppColors.error,
                                  size: 64,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              Text(
                                "PDF Document",
                                style: AppTextStyles.bodyLg.copyWith(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xl,
                                ),
                                child: Text(
                                  path.split('/').last,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.caption.copyWith(
                                    color: colors.textTertiary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                "Document preview loaded from server",
                                style: AppTextStyles.overline.copyWith(
                                  color: AppColors.success,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colors.divider.withAlpha(30),
                    width: 0.5,
                  ),
                  color: colors.divider.withAlpha(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.textSecondary,
                          side: BorderSide(
                            color: colors.divider.withAlpha(isDark ? 80 : 150),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.pillAll,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md + 2,
                          ),
                        ),
                        child: Text(
                          "Close",
                          style: AppTextStyles.buttonText,
                        ),
                      ),
                    ),
                    if (onReplace != null) ...[
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Navigator.pop(context);
                            onReplace!();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.pillAll,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md + 2,
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.upload_file_rounded, size: 18),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                "Replace",
                                style: AppTextStyles.buttonText,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
