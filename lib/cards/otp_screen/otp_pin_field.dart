import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';

class OtpPinField extends StatelessWidget {
  final List<String> digits;
  final bool isError;
  final bool isSuccess;
  final int activeIndex;

  const OtpPinField({
    super.key,
    required this.digits,
    this.isError = false,
    this.isSuccess = false,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isFilled = digits[index].isNotEmpty;
        final isActive = index == activeIndex && !isSuccess;

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

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: 64,
            height: 72,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: AppRadius.lgAll,
              border: Border.all(
                color: borderColor,
                width: isActive ? 2.0 : 1.5,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(30),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (child, anim) {
                  return ScaleTransition(scale: anim, child: child);
                },
                child: isFilled
                    ? Text(
                        digits[index],
                        key: ValueKey('digit_${index}_${digits[index]}'),
                        style: AppTextStyles.headingLg.copyWith(
                          color: isError
                              ? AppColors.error
                              : isSuccess
                                  ? AppColors.success
                                  : colors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : isActive
                        ? _BlinkingCursor(colors: colors)
                        : const SizedBox.shrink(key: ValueKey('empty')),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  final C colors;
  const _BlinkingCursor({required this.colors});

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 2,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
