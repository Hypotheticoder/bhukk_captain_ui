import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneInputCard extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isError;
  final String errorMessage;
  final bool isLoading;
  final VoidCallback onSendOtp;

  const PhoneInputCard({
    super.key,
    required this.controller,
    required this.focusNode,
    this.isError = false,
    this.errorMessage = '',
    this.isLoading = false,
    required this.onSendOtp,
  });

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phone label
        Text(
          "Phone Number",
          style: AppTextStyles.label.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Phone input row
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: AppRadius.xlAll,
            border: Border.all(
              color: isError
                  ? AppColors.error
                  : focusNode.hasFocus
                      ? AppColors.primary
                      : colors.divider,
              width: isError || focusNode.hasFocus ? 1.5 : 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.cardShadow(0.04),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Country code
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg + 2,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: colors.divider,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "🇮🇳",
                      style: AppTextStyles.bodyMd,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      "+91",
                      style: AppTextStyles.bodyMd.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // Phone number input
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: "Enter mobile number",
                    hintStyle: AppTextStyles.bodySm.copyWith(
                      color: colors.textTertiary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.lg,
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Error message
        if (isError && errorMessage.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.sm),
            child: Text(
              errorMessage,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.xxl),

        // Send OTP button
        GestureDetector(
          onTap: isLoading ? null : onSendOtp,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryAccent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: AppRadius.pillAll,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(80),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      "Send OTP",
                      style: AppTextStyles.buttonText.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
