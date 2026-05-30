import 'package:bhukkdelivery/providers/edit_profile/edit_profile_provider.dart';
import 'package:bhukkdelivery/providers/profile/profile_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:bhukkdelivery/widgets/document_viewer_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BikeDocumentsCard extends ConsumerWidget {
  const BikeDocumentsCard({super.key});

  static const Map<IconType, IconData> _icons = {
    IconType.rc: Icons.description_outlined,
    IconType.insurance: Icons.shield_outlined,
    IconType.dl: Icons.badge_outlined,
    IconType.puc: Icons.eco_outlined,
  };

  static const Map<IconType, String> _docTypeKeys = {
    IconType.rc: 'rc',
    IconType.dl: 'dl',
    IconType.insurance: 'insurance',
    IconType.puc: 'pan', // PUC mapped to pan slot
  };

  Future<void> _pickFile(
      BuildContext context, WidgetRef ref, int index, String docType) async {
    HapticFeedback.selectionClick();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      // Update edit profile state
      ref.read(editProfileProvider.notifier).uploadDocument(index, path);
      // Update profile provider with actual file path
      ref.read(profileProvider.notifier).setDocument(docType, path);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Document uploaded successfully!"),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = C.of(context);
    final documents = ref.watch(
      editProfileProvider.select((s) => s.documents),
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: documents.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final doc = documents[index];
        final docType = _docTypeKeys[doc.iconType] ?? 'rc';
        return _DocumentTile(
          doc: doc,
          icon: _icons[doc.iconType] ?? Icons.file_present_outlined,
          colors: colors,
          onTap: () => _pickFile(context, ref, index, docType),
        );
      },
    );
  }
}

class _DocumentTile extends StatefulWidget {
  final BikeDocument doc;
  final IconData icon;
  final C colors;
  final VoidCallback onTap;

  const _DocumentTile({
    required this.doc,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  State<_DocumentTile> createState() => _DocumentTileState();
}

class _DocumentTileState extends State<_DocumentTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    final isUploaded = widget.doc.status == DocumentStatus.uploaded;
    final statusColor = isUploaded ? AppColors.success : AppColors.warning;

    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        if (!isUploaded) {
          widget.onTap();
        } else {
          showDialog(
            context: context,
            builder: (ctx) => DocumentViewerDialog(
              title: widget.doc.title,
              path: widget.doc.url ?? '',
              onReplace: widget.onTap,
            ),
          );
        }
      },
      onTapCancel: () => _scaleController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            color: c.surfaceElevated,
            borderRadius: AppRadius.xlAll,
            border: Border.all(
              color: isUploaded
                  ? AppColors.success.withAlpha(c.isDark ? 60 : 40)
                  : c.blush.withAlpha(c.isDark ? 40 : 100),
              width: 1.5,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
            boxShadow: [
              BoxShadow(
                color: c.cardShadow(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusColor.withAlpha(c.isDark ? 45 : 25),
                      statusColor.withAlpha(c.isDark ? 20 : 10),
                    ],
                  ),
                  borderRadius: AppRadius.mdAll,
                ),
                child: Icon(
                  isUploaded ? Icons.check_circle_rounded : widget.icon,
                  color: statusColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  widget.doc.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(c.isDark ? 30 : 15),
                  borderRadius: AppRadius.pillAll,
                ),
                child: Text(
                  isUploaded ? "Uploaded" : "Tap to upload",
                  style: AppTextStyles.overline.copyWith(
                    fontSize: 9,
                    color: statusColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
