import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:bhukkdelivery/providers/otp/otp_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  final GlobalKey<_ShakeWidgetState> _shakeKey = GlobalKey<_ShakeWidgetState>();
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    // Initialize OTP type based on delivery status synchronously
    final delivery = ref.read(activeDeliveryProvider);
    if (delivery != null && delivery.currentOtpType != null) {
      Future.microtask(() {
        if (mounted) {
          ref.read(otpProvider.notifier).initialize(delivery.currentOtpType!);
        }
      });
    }

    // Focus the first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Animation<double> _stagger(int index) {
    final start = (index * 0.15).clamp(0.0, 0.6);
    final end = (start + 0.4).clamp(0.0, 1.0);
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  void _onDigitChanged(int index, String value) {
    if (value.length == 1) {
      ref.read(otpProvider.notifier).setDigit(value);
      if (index < 3) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        ref.read(otpProvider.notifier).deleteDigit();
        _focusNodes[index - 1].requestFocus();
      } else if (_controllers[index].text.isNotEmpty) {
        _controllers[index].clear();
        ref.read(otpProvider.notifier).deleteDigit();
      }
    }
  }

  Future<void> _handleVerify() async {
    final success = await ref.read(otpProvider.notifier).verify();
    if (success && mounted) {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) context.pop(true);
    } else if (!success && mounted) {
      HapticFeedback.heavyImpact();
      _shakeKey.currentState?.shake();
      // Clear all text fields
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    final otpState = ref.watch(otpProvider);
    final delivery = ref.watch(activeDeliveryProvider);

    // Auto-submit when all 4 digits are entered
    ref.listen(otpProvider, (prev, next) {
      if (next.isComplete &&
          !next.isVerifying &&
          !next.isError &&
          !next.isSuccess) {
        Future.microtask(() {
          if (mounted) _handleVerify();
        });
      }
    });

    final isPickup = otpState.otpType == OtpType.pickup;

    final isRide = delivery?.isRide ?? false;
    final isParcel = delivery?.isParcel ?? false;


    final title = isRide
        ? (isPickup ? 'Pickup OTP' : 'Drop OTP')
        : isParcel
        ? (isPickup ? 'Arrived OTP' : 'Delivered OTP')
        : otpState.title;

    final subtitle = isRide
        ? (isPickup
              ? 'Enter the OTP to start the trip'
              : 'Enter the OTP to complete the trip')
        : isParcel
        ? (isPickup
              ? 'Enter the OTP to confirm arrival at pickup'
              : 'Enter the OTP to confirm delivery')
        : otpState.subtitle;

    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: true,
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            bottom: MediaQuery.of(context).viewInsets.bottom + 100,
          ),
          child: AnimatedBuilder(
            animation: _entryController,
            builder: (context, _) {
              return Column(
                children: [
                  const SizedBox(height: AppSpacing.xxl),

                  // Icon
                  FadeTransition(
                    opacity: _stagger(0),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(_stagger(0)),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(scale: value, child: child);
                        },
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                (isPickup
                                        ? AppColors.warning
                                        : AppColors.success)
                                    .withAlpha(colors.isDark ? 50 : 30),
                                (isPickup
                                        ? AppColors.warning
                                        : AppColors.success)
                                    .withAlpha(colors.isDark ? 20 : 10),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPickup
                                ? Icons.store_rounded
                                : Icons.location_on_rounded,
                            size: 32,
                            color: isPickup
                                ? AppColors.warning
                                : AppColors.success,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Title
                  FadeTransition(
                    opacity: _stagger(1),
                    child: Text(
                      title,
                      style: AppTextStyles.headingMd.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Subtitle
                  FadeTransition(
                    opacity: _stagger(1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySm.copyWith(
                          color: colors.textTertiary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),


                  const SizedBox(height: AppSpacing.xxxl),

                  // Pin input fields
                  FadeTransition(
                    opacity: _stagger(2),
                    child: _ShakeWidget(
                      key: _shakeKey,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          final isFilled = _controllers[index].text.isNotEmpty;
                          final isActive = _focusNodes[index].hasFocus;

                          Color borderColor;
                          Color bgColor;
                          if (otpState.isError) {
                            borderColor = AppColors.error;
                            bgColor = AppColors.error.withAlpha(
                              colors.isDark ? 20 : 10,
                            );
                          } else if (otpState.isSuccess) {
                            borderColor = AppColors.success;
                            bgColor = AppColors.success.withAlpha(
                              colors.isDark ? 20 : 10,
                            );
                          } else if (isActive) {
                            borderColor = AppColors.primary;
                            bgColor = AppColors.primary.withAlpha(
                              colors.isDark ? 15 : 8,
                            );
                          } else if (isFilled) {
                            borderColor = AppColors.primary.withAlpha(120);
                            bgColor = colors.surfaceElevated;
                          } else {
                            borderColor = colors.divider;
                            bgColor = colors.surfaceElevated;
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
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
                                          color: AppColors.primary.withAlpha(
                                            30,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: KeyboardListener(
                                focusNode: FocusNode(),
                                onKeyEvent: (event) =>
                                    _onKeyEvent(index, event),
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  style: AppTextStyles.headingLg.copyWith(
                                    color: otpState.isError
                                        ? AppColors.error
                                        : otpState.isSuccess
                                        ? AppColors.success
                                        : colors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                    height: 1.0,
                                  ),
                                  decoration: const InputDecoration(
                                    counterText: '',
                                    border: InputBorder.none,
                                    isCollapsed: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 20,
                                    ),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(1),
                                  ],
                                  onChanged: (value) =>
                                      _onDigitChanged(index, value),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  // Error text
                  const SizedBox(height: AppSpacing.lg),
                  AnimatedOpacity(
                    opacity: otpState.isError ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      otpState.errorMessage ?? "Invalid OTP. Please try again.",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Success text
                  AnimatedOpacity(
                    opacity: otpState.isSuccess ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 18,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          isRide
                              ? (isPickup
                                    ? 'Pickup confirmed!'
                                    : 'Trip completed!')
                              : isParcel
                              ? (isPickup
                                    ? 'Arrival confirmed!'
                                    : 'Delivery verified!')
                              : (isPickup
                                    ? 'Pickup confirmed!'
                                    : 'Delivery verified!'),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  // Verify button
                  FadeTransition(
                    opacity: _stagger(3),
                    child: GestureDetector(
                      onTap:
                          otpState.isComplete &&
                              !otpState.isVerifying &&
                              !otpState.isSuccess
                          ? _handleVerify
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: otpState.isSuccess
                              ? AppColors.success
                              : otpState.isComplete
                              ? AppColors.primary
                              : colors.divider,
                          borderRadius: AppRadius.pillAll,
                          boxShadow: otpState.isComplete
                              ? [
                                  BoxShadow(
                                    color:
                                        (otpState.isSuccess
                                                ? AppColors.success
                                                : AppColors.primary)
                                            .withAlpha(80),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: otpState.isVerifying
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : otpState.isSuccess
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 28,
                                )
                              : Text(
                                  "Verify OTP",
                                  style: AppTextStyles.buttonText.copyWith(
                                    color: otpState.isComplete
                                        ? Colors.white
                                        : colors.textTertiary,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Shake animation widget for error feedback
class _ShakeWidget extends StatefulWidget {
  final Widget child;
  const _ShakeWidget({super.key, required this.child});

  @override
  State<_ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<_ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _offsetAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12, end: 12), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void shake() {
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_offsetAnim.value, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
