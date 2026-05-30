import 'package:bhukkdelivery/cards/login_screen/login_otp_card.dart';
import 'package:bhukkdelivery/cards/login_screen/phone_input_card.dart';
import 'package:bhukkdelivery/notifiers/login_screen/login_notifier.dart';
import 'package:bhukkdelivery/providers/login/login_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _stepController;

  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();

  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _stepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _phoneFocusNode.addListener(() => setState(() {}));
    for (final fn in _otpFocusNodes) {
      fn.addListener(() => setState(() {}));
    }

    _phoneController.addListener(() {
      ref.read(loginProvider.notifier).setPhoneNumber(_phoneController.text);
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _stepController.dispose();
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Animation<double> _stagger(int index) {
    final start = (index * 0.12).clamp(0.0, 0.6);
    final end = (start + 0.4).clamp(0.0, 1.0);
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1) {
      ref.read(loginProvider.notifier).setOtpDigit(value);
      if (index < 5) {
        _otpFocusNodes[index + 1].requestFocus();
      } else {
        _otpFocusNodes[index].unfocus();
      }
    }
  }

  void _onOtpKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_otpControllers[index].text.isEmpty && index > 0) {
        ref.read(loginProvider.notifier).deleteOtpDigit();
        _otpFocusNodes[index - 1].requestFocus();
      } else if (_otpControllers[index].text.isNotEmpty) {
        _otpControllers[index].clear();
        ref.read(loginProvider.notifier).deleteOtpDigit();
      }
    }
  }

  Future<void> _handleSendOtp() async {
    HapticFeedback.mediumImpact();
    _phoneFocusNode.unfocus();
    await ref.read(loginProvider.notifier).sendOtp();

    final loginState = ref.read(loginProvider);

    // If driver doesn't exist, redirect to register with phone pre-filled
    if (loginState.shouldRedirectToRegister && mounted) {
      context.push('/register?phone=${loginState.phoneNumber}');
      return;
    }

    // If OTP was sent, move to OTP step
    if (loginState.step == LoginStep.otp) {
      _stepController.forward();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _otpFocusNodes[0].requestFocus();
      });
    }
  }

  Future<void> _handleVerify() async {
    HapticFeedback.mediumImpact();
    final success = await ref.read(loginProvider.notifier).verifyOtp();
    if (success && mounted) {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) context.go('/home');
    } else if (!success && mounted) {
      HapticFeedback.heavyImpact();
      for (final c in _otpControllers) {
        c.clear();
      }
      _otpFocusNodes[0].requestFocus();
    }
  }

  void _handleGoBack() {
    _stepController.reverse();
    ref.read(loginProvider.notifier).goBackToPhone();
    for (final c in _otpControllers) {
      c.clear();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _phoneFocusNode.requestFocus();
    });
  }

  void _handleResend() async {
    for (final c in _otpControllers) {
      c.clear();
    }
    await ref.read(loginProvider.notifier).resendOtp();
    _otpFocusNodes[0].requestFocus();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "OTP resent successfully!",
            style: AppTextStyles.caption.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    final loginState = ref.watch(loginProvider);

    // Auto-submit when all 6 OTP digits are entered
    ref.listen(loginProvider, (prev, next) {
      if (next.step == LoginStep.otp &&
          next.isOtpComplete &&
          !next.isVerifyingOtp &&
          !next.isError &&
          !next.isSuccess) {
        Future.microtask(() {
          if (mounted) _handleVerify();
        });
      }
    });

    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background orbs
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withAlpha(colors.isDark ? 25 : 15),
                    AppColors.primary.withAlpha(0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryAccent.withAlpha(colors.isDark ? 20 : 10),
                    AppColors.primaryAccent.withAlpha(0),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: AppSpacing.xxl,
                right: AppSpacing.xxl,
                top: AppSpacing.xxl,
                bottom: MediaQuery.of(context).viewInsets.bottom + 40,
              ),
              child: AnimatedBuilder(
                animation: Listenable.merge([_entryController, _stepController]),
                builder: (context, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.huge),

                      // Logo / Brand icon
                      FadeTransition(
                        opacity: _stagger(0),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(_stagger(0)),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryAccent,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: AppRadius.xlAll,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withAlpha(60),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.delivery_dining_rounded,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Title
                      FadeTransition(
                        opacity: _stagger(1),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.2),
                            end: Offset.zero,
                          ).animate(_stagger(1)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loginState.step == LoginStep.phone
                                    ? "Welcome Back 👋"
                                    : "Verify OTP",
                                style: AppTextStyles.headingLg.copyWith(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                loginState.step == LoginStep.phone
                                    ? "Sign in to start delivering happiness"
                                    : "Enter the 6-digit code",
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: colors.textTertiary,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxxl + AppSpacing.lg),

                      // Step: Phone or OTP
                      FadeTransition(
                        opacity: _stagger(2),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.05, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: loginState.step == LoginStep.phone
                              ? PhoneInputCard(
                                  key: const ValueKey('phone'),
                                  controller: _phoneController,
                                  focusNode: _phoneFocusNode,
                                  isError: loginState.isError &&
                                      loginState.step == LoginStep.phone,
                                  errorMessage: loginState.errorMessage,
                                  isLoading: loginState.isSendingOtp,
                                  onSendOtp: _handleSendOtp,
                                )
                              : LoginOtpCard(
                                  key: const ValueKey('otp'),
                                  controllers: _otpControllers,
                                  focusNodes: _otpFocusNodes,
                                  isError: loginState.isError,
                                  isSuccess: loginState.isSuccess,
                                  isVerifying: loginState.isVerifyingOtp,
                                  errorMessage: loginState.errorMessage,
                                  maskedPhone: loginState.maskedPhone,
                                  onVerify: _handleVerify,
                                  onResend: _handleResend,
                                  onChangeNumber: _handleGoBack,
                                  onChanged: _onOtpChanged,
                                  onKeyEvent: _onOtpKeyEvent,
                                ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),



                      const SizedBox(height: AppSpacing.xxl),

                      // Register link
                      FadeTransition(
                        opacity: _stagger(4),
                        child: Center(
                          child: GestureDetector(
                            onTap: () => context.push('/register'),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md),
                              child: RichText(
                                text: TextSpan(
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: colors.textTertiary,
                                  ),
                                  children: [
                                    const TextSpan(text: "New here? "),
                                    TextSpan(
                                      text: "Register now",
                                      style: AppTextStyles.bodySm.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Footer
                      FadeTransition(
                        opacity: _stagger(4),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                            child: Text(
                              "By continuing, you agree to our Terms & Privacy Policy",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.caption.copyWith(
                                color: colors.textTertiary.withAlpha(150),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
