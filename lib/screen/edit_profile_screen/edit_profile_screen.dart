import 'package:bhukkdelivery/cards/edit_profile_screen/bike_documents_card.dart';
import 'package:bhukkdelivery/cards/edit_profile_screen/edit_profile_header_card.dart';
import 'package:bhukkdelivery/cards/edit_profile_screen/personal_details_form_card.dart';
import 'package:bhukkdelivery/cards/edit_profile_screen/save_profile_button_card.dart';
import 'package:bhukkdelivery/cards/edit_profile_screen/vehicle_details_form_card.dart';
import 'package:bhukkdelivery/providers/edit_profile/edit_profile_provider.dart';
import 'package:bhukkdelivery/providers/profile/profile_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Animation<double> _staggeredFade(int index) {
    final start = (index * 0.1).clamp(0.0, 0.7);
    final end = (start + 0.3).clamp(0.0, 1.0);
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  Animation<Offset> _staggeredSlide(int index) {
    final start = (index * 0.1).clamp(0.0, 0.7);
    final end = (start + 0.3).clamp(0.0, 1.0);
    return Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    final profile = ref.watch(profileProvider);

    // Pre-fill form from profile on first build
    if (!_initialized && profile != null) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(editProfileProvider.notifier).initFromProfile(
              name: profile.name,
              phone: profile.phone,
              email: profile.email,
              vehicleType: profile.vehicleType,
              vehicleNumber: profile.vehicleNumber,
              rcPath: profile.rcBookPath,
              insurancePath: profile.insurancePath,
              dlPath: profile.drivingLicensePath,
              pucPath: profile.panCardPath,
            );
      });
    }

    final sections = <Widget>[
      const EditProfileHeaderCard(),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Personal Details", colors),
          const PersonalDetailsFormCard(),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Vehicle Information", colors),
          const VehicleDetailsFormCard(),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Bike Documents", colors),
          const SizedBox(height: AppSpacing.xs),
          Text(
            "Upload your vehicle documents for verification",
            style: AppTextStyles.caption.copyWith(
              color: colors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const BikeDocumentsCard(),
        ],
      ),
      const SaveProfileButtonCard(),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: AppRadius.mdAll,
              boxShadow: [
                BoxShadow(
                  color: colors.cardShadow(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: colors.textPrimary,
              size: 22,
            ),
          ),
        ),
        title: Text(
          "Edit Profile",
          style: AppTextStyles.headingSm.copyWith(
            color: colors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: _staggerController,
        builder: (context, _) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < sections.length; i++) ...[
                  SlideTransition(
                    position: _staggeredSlide(i),
                    child: FadeTransition(
                      opacity: _staggeredFade(i),
                      child: sections[i],
                    ),
                  ),
                  if (i < sections.length - 1)
                    const SizedBox(height: AppSpacing.xxl),
                ],
                const SizedBox(height: AppSpacing.huge),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, C colors) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: AppSpacing.md, left: AppSpacing.xs),
      child: Text(
        title,
        style: AppTextStyles.bodyLg.copyWith(
          color: colors.textPrimary.withAlpha(204),
        ),
      ),
    );
  }
}
