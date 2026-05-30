import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginOtpCard extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool isError;
  final bool isSuccess;
  final bool isVerifying;
  final String errorMessage;
  final String maskedPhone;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final VoidCallback onChangeNumber;
  final void Function(int index, String value) onChanged;
  final void Function(int index, KeyEvent event) onKeyEvent;

  const LoginOtpCard({
    super.key,
    required this.controllers,
    required this.focusNodes,
    this.isError = false,
    this.isSuccess = false,
    this.isVerifying = false,
    this.errorMessage = '',
    required this.maskedPhone,
    required this.onVerify,
    required this.onResend,
    required this.onChangeNumber,
    required this.onChanged,
    required this.onKeyEvent,
  });

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description
        RichText(
          text: TextSpan(
            style: AppTextStyles.bodySm.copyWith(
              color: colors.textTertiary,
              height: 1.6,
            ),
            children: [
              const TextSpan(text: "We sent a 6-digit code to "),
              TextSpan(
                text: "+91 $maskedPhone",
                style: AppTextStyles.bodySm.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // OTP boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            final isFilled = controllers[index].text.isNotEmpty;
            final isActive = focusNodes[index].hasFocus;

            Color borderColor;
            Color bgColor;
            if (isError) {
              borderColor = AppColors.error;
              bgColor = AppColors.error.withAlpha(colors.isDark ? 20 : 10);
            } else if (isSuccess) {
              borderColor = AppColors.success;
              bgColor = AppColors.success.withAlpha(colors.isDark ? 20 : 10);
            } else if (isActive) {
              borderColor = AppColors.primary;
              bgColor = AppColors.primary.withAlpha(colors.isDark ? 15 : 8);
            } else if (isFilled) {
              borderColor = AppColors.primary.withAlpha(120);
              bgColor = colors.surfaceElevated;
            } else {
              borderColor = colors.divider;
              bgColor = colors.surfaceElevated;
            }

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : 4,
                  right: index == 5 ? 0 : 4,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 56,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: AppRadius.mdAll,
                    border: Border.all(
                      color: borderColor,
                      width: isActive ? 2.0 : 1.0,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: KeyboardListener(
                    focusNode: FocusNode(),
                    onKeyEvent: (event) => onKeyEvent(index, event),
                    child: TextField(
                      controller: controllers[index],
                      focusNode: focusNodes[index],
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: AppTextStyles.headingSm.copyWith(
                        color: isError
                            ? AppColors.error
                            : isSuccess
                                ? AppColors.success
                                : colors.textPrimary,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      onChanged: (value) => onChanged(index, value),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),

        // Error message
        if (isError && errorMessage.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              errorMessage,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],

        // Success message
        if (isSuccess) ...[
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 18),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  "Verified successfully!",
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.xxl),

        // Verify button
        GestureDetector(
          onTap: isVerifying || isSuccess ? null : onVerify,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: isSuccess
                  ? LinearGradient(
                      colors: [
                        AppColors.success,
                        AppColors.success.withAlpha(200),
                      ],
                    )
                  : const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryAccent],
                    ),
              borderRadius: AppRadius.pillAll,
              boxShadow: [
                BoxShadow(
                  color: (isSuccess ? AppColors.success : AppColors.primary)
                      .withAlpha(80),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: isVerifying
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : isSuccess
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 28)
                      : Text(
                          "Verify & Login",
                          style: AppTextStyles.buttonText.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Bottom actions
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onResend,
              child: Text(
                "Resend OTP",
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                "·",
                style: AppTextStyles.bodySm.copyWith(color: colors.divider),
              ),
            ),
            GestureDetector(
              onTap: onChangeNumber,
              child: Text(
                "Change Number",
                style: AppTextStyles.caption.copyWith(
                  color: colors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
