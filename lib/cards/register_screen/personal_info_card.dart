import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PersonalInfoCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController cityController;
  final String dateOfBirth;
  final ValueChanged<String> onDateOfBirthChanged;
  final String? errorMessage;

  const PersonalInfoCard({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.cityController,
    required this.dateOfBirth,
    required this.onDateOfBirthChanged,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildField(
          context,
          label: "Full Name",
          hint: "e.g. Rajesh Kumar",
          icon: Icons.person_outline_rounded,
          controller: nameController,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildField(
          context,
          label: "Email Address",
          hint: "e.g. rajesh@email.com",
          icon: Icons.email_outlined,
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.xl),
        // Phone with country code
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Phone Number",
              style: AppTextStyles.caption.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: AppRadius.lgAll,
                border: Border.all(color: colors.divider, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: colors.cardShadow(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md + 2,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: colors.divider, width: 0.5),
                      ),
                    ),
                    child: Text(
                      "🇮🇳 +91",
                      style: AppTextStyles.bodySm.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      textInputAction: TextInputAction.next,
                      style: AppTextStyles.bodySm.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: "Mobile number",
                        hintStyle: AppTextStyles.bodySm.copyWith(
                          color: colors.textTertiary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildField(
          context,
          label: "City",
          hint: "e.g. Mumbai",
          icon: Icons.location_city_rounded,
          controller: cityController,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: AppSpacing.xl),
        // Date of Birth picker
        _buildDobField(context),

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

  Widget _buildField(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    final colors = C.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: colors.divider, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: colors.cardShadow(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            style: AppTextStyles.bodySm.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodySm.copyWith(
                color: colors.textTertiary,
              ),
              prefixIcon: Icon(icon, color: colors.textTertiary, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md + 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDobField(BuildContext context) {
    final colors = C.of(context);
    final hasValue = dateOfBirth.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Date of Birth",
          style: AppTextStyles.caption.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(now.year - 20),
              firstDate: DateTime(1950),
              lastDate: DateTime(now.year - 18),
              helpText: 'Select your date of birth',
            );
            if (picked != null) {
              final formatted =
                  '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
              onDateOfBirthChanged(formatted);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md + 2,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: AppRadius.lgAll,
              border: Border.all(color: colors.divider, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: colors.cardShadow(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: colors.textTertiary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  hasValue ? dateOfBirth : 'Select date of birth',
                  style: AppTextStyles.bodySm.copyWith(
                    color: hasValue ? colors.textPrimary : colors.textTertiary,
                    fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
