import 'package:bhukkdelivery/cards/profile_screen/performance_stats_card.dart';
import 'package:bhukkdelivery/cards/profile_screen/profile_actions_card.dart';
import 'package:bhukkdelivery/cards/profile_screen/profile_header_card.dart';
import 'package:bhukkdelivery/cards/profile_screen/profile_info_card.dart';
import 'package:bhukkdelivery/providers/profile/profile_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:bhukkdelivery/cards/home/promo_ads_card.dart';
import 'package:bhukkdelivery/widgets/support_popup.dart';
import 'package:bhukkdelivery/widgets/document_viewer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final colors = C.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: profile == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + AppSpacing.xl,
                bottom: 120,
                left: AppSpacing.xl,
                right: AppSpacing.xl,
              ),
              child: Column(
                children: [
                  ProfileHeaderCard(profile: profile),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildSectionTitle("Personal Details", colors),
                  ProfileInfoCard(
                    rows: [
                      ProfileInfoRow(
                          icon: Icons.person_outline,
                          label: "Name",
                          value: profile.name),
                      ProfileInfoRow(
                          icon: Icons.phone_outlined,
                          label: "Phone",
                          value: profile.phone),
                      ProfileInfoRow(
                          icon: Icons.email_outlined,
                          label: "Email",
                          value: profile.email),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildSectionTitle("Vehicle Information", colors),
                  ProfileInfoCard(
                    rows: [
                      ProfileInfoRow(
                          icon: Icons.two_wheeler_outlined,
                          label: "Vehicle",
                          value: profile.vehicleDisplay),
                      if (profile.vehicleNumber.isNotEmpty)
                        ProfileInfoRow(
                            icon: Icons.confirmation_number_outlined,
                            label: "Reg. Number",
                            value: profile.vehicleNumber),
                      if (profile.vehicleColor.isNotEmpty)
                        ProfileInfoRow(
                            icon: Icons.palette_outlined,
                            label: "Color",
                            value: profile.vehicleColor),
                    ],
                  ),
              const SizedBox(height: AppSpacing.xxl),
                  _buildSectionTitle("Bank Details", colors),
                  _buildBankDetailsSection(profile, colors, ref),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildSectionTitle("Documents", colors),
                  _buildDocumentStatus(profile, colors, context),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildSectionTitle("Performance", colors),
                  PerformanceStatsCard(profile: profile),
                  const SizedBox(height: AppSpacing.xxl),
                  const PromoAdsCard(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildSupportRow(context, ref, colors),
                  const SizedBox(height: AppSpacing.xxxl),
                  const ProfileActionsCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title, C colors) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: AppSpacing.md, left: AppSpacing.xs),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: AppTextStyles.bodyLg.copyWith(
            color: colors.textPrimary.withAlpha(204),
          ),
        ),
      ),
    );
  }

  Widget _buildSupportRow(BuildContext context, WidgetRef ref, C colors) {
    return GestureDetector(
      onTap: () => showSupportPopup(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: colors.glassCardStrong,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.darkCyan, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.headset_mic_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Call Support',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '24/7 available • Tap to call',
                    style: AppTextStyles.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: colors.textTertiary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentStatus(UserProfile profile, C colors, BuildContext context) {
    final docs = <_DocItem>[
      _DocItem("Driving License", Icons.credit_card_rounded,
          profile.drivingLicensePath != null, profile.drivingLicensePath),
      _DocItem("RC Book", Icons.description_rounded,
          profile.rcBookPath != null, profile.rcBookPath),
      _DocItem("Insurance", Icons.security_rounded,
          profile.insurancePath != null, profile.insurancePath),
      _DocItem(
          "PAN Card", Icons.badge_rounded, profile.panCardPath != null, profile.panCardPath),
      _DocItem("Aadhar Card", Icons.fingerprint_rounded,
          profile.aadharCardPath != null, profile.aadharCardPath),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: colors.card,
      child: Column(
        children: [
          // Upload count
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(colors.isDark ? 25 : 15),
                  borderRadius: AppRadius.mdAll,
                ),
                child: Icon(
                  Icons.folder_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  "${profile.uploadedDocsCount} of 6 documents uploaded",
                  style: AppTextStyles.bodySm.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Document list
          ...docs.map((doc) {
            return InkWell(
              onTap: doc.isUploaded
                  ? () {
                      HapticFeedback.lightImpact();
                      showDialog(
                        context: context,
                        builder: (ctx) => DocumentViewerDialog(
                          title: doc.title,
                          path: doc.path ?? '',
                        ),
                      );
                    }
                  : null,
              borderRadius: AppRadius.mdAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    Icon(
                      doc.isUploaded
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: doc.isUploaded
                          ? AppColors.success
                          : colors.textTertiary,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Icon(doc.icon, color: colors.textTertiary, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        doc.title,
                        style: AppTextStyles.bodySm.copyWith(
                          color: colors.textPrimary.withAlpha(200),
                          decoration: doc.isUploaded
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (doc.isUploaded) ...[
                          const Icon(
                            Icons.visibility_outlined,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          doc.isUploaded ? "View" : "Pending",
                          style: AppTextStyles.caption.copyWith(
                            color: doc.isUploaded
                                ? AppColors.primary
                                : AppColors.warning,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Bank Details Section ───
  Widget _buildBankDetailsSection(
      UserProfile profile, C colors, WidgetRef ref) {
    if (profile.hasBankDetails) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: colors.card,
        child: Column(
          children: [
            // Header row with edit button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color:
                        AppColors.primary.withAlpha(colors.isDark ? 25 : 15),
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: const Icon(Icons.account_balance_rounded,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    "Bank Account Linked",
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      _showBankDetailsDialog(ref.context, profile, ref),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(15),
                      borderRadius: AppRadius.pillAll,
                    ),
                    child: Text(
                      'Edit',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            // Bank info rows
            _bankRow(Icons.person_outline, "Holder",
                profile.bankAccountHolder ?? '', colors),
            _bankRow(Icons.credit_card_rounded, "Account",
                profile.maskedAccountNumber, colors),
            _bankRow(Icons.account_balance_rounded, "IFSC",
                profile.bankIfscCode ?? '', colors),
            if (profile.bankUpiId != null && profile.bankUpiId!.isNotEmpty)
              _bankRow(
                  Icons.qr_code_2_rounded, "UPI", profile.bankUpiId!, colors),
          ],
        ),
      );
    }

    // Empty state
    return GestureDetector(
      onTap: () => _showBankDetailsDialog(ref.context, profile, ref),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: colors.card,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance_outlined,
                  color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No bank details added',
              style: AppTextStyles.bodyMd.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Add your bank account to withdraw earnings easily.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySm
                  .copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.pillAll,
              ),
              child: Text(
                '+ Add Bank Details',
                style: AppTextStyles.bodySm.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bankRow(IconData icon, String label, String value, C colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 1),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.textTertiary),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: AppTextStyles.caption
                  .copyWith(color: colors.textTertiary),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMd.copyWith(
                color: colors.textPrimary.withAlpha(222),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBankDetailsDialog(
      BuildContext context, UserProfile profile, WidgetRef ref) {
    final holderCtrl =
        TextEditingController(text: profile.bankAccountHolder ?? '');
    final accountCtrl =
        TextEditingController(text: profile.bankAccountNumber ?? '');
    final ifscCtrl =
        TextEditingController(text: profile.bankIfscCode ?? '');
    final upiCtrl =
        TextEditingController(text: profile.bankUpiId ?? '');
    final formKey = GlobalKey<FormState>();

    final colors = C.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xlAll,
        ),
        title: Row(
          children: [
            const Icon(Icons.account_balance_rounded,
                color: AppColors.primary, size: 22),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Bank Details',
              style: AppTextStyles.bodyLg.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(holderCtrl, 'Account Holder Name',
                    'As per bank records', colors,
                    capitalization: TextCapitalization.words,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Required'
                        : null),
                const SizedBox(height: AppSpacing.md),
                _dialogField(accountCtrl, 'Account Number',
                    'Enter account number', colors,
                    keyboardType: TextInputType.number,
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (v.trim().length < 8) return 'Invalid';
                  return null;
                }),
                const SizedBox(height: AppSpacing.md),
                _dialogField(
                    ifscCtrl, 'IFSC Code', 'e.g. SBIN0001234', colors,
                    capitalization: TextCapitalization.characters,
                    validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (!RegExp(r'^[A-Z]{4}[0-9A-Z]{7}$')
                      .hasMatch(v.trim().toUpperCase())) {
                    return 'Invalid IFSC';
                  }
                  return null;
                }),
                const SizedBox(height: AppSpacing.md),
                _dialogField(
                    upiCtrl, 'UPI ID (Optional)', 'yourname@upi', colors,
                    keyboardType: TextInputType.emailAddress),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.pillAll),
            ),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              ref.read(profileProvider.notifier).updateProfile(
                    bankAccountHolder: holderCtrl.text.trim(),
                    bankAccountNumber: accountCtrl.text.trim(),
                    bankIfscCode:
                        ifscCtrl.text.trim().toUpperCase(),
                    bankUpiId: upiCtrl.text.trim().isNotEmpty
                        ? upiCtrl.text.trim()
                        : null,
                  );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Bank details saved!'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.mdAll),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(
    TextEditingController controller,
    String label,
    String hint,
    C colors, {
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.none,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: capitalization,
      inputFormatters: formatters,
      validator: validator,
      style: AppTextStyles.bodyMd.copyWith(color: colors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle:
            AppTextStyles.caption.copyWith(color: colors.textSecondary),
        hintStyle:
            AppTextStyles.bodySm.copyWith(color: colors.textTertiary),
        filled: true,
        fillColor: colors.blush.withAlpha(colors.isDark ? 15 : 40),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: AppRadius.lgAll,
          borderSide: BorderSide(color: colors.divider.withAlpha(50)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgAll,
          borderSide: BorderSide(color: colors.divider.withAlpha(50)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgAll,
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _DocItem {
  final String title;
  final IconData icon;
  final bool isUploaded;
  final String? path;

  const _DocItem(this.title, this.icon, this.isUploaded, [this.path]);
}
