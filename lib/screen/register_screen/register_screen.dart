import 'package:bhukkdelivery/cards/register_screen/document_upload_card.dart';
import 'package:bhukkdelivery/cards/register_screen/personal_info_card.dart';
import 'package:bhukkdelivery/cards/register_screen/vehicle_info_card.dart';
import 'package:bhukkdelivery/notifiers/register_screen/register_notifier.dart';
import 'package:bhukkdelivery/providers/register/register_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String? prefilledPhone;

  const RegisterScreen({super.key, this.prefilledPhone});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;

  // Personal info controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  // Vehicle info controllers
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    // Pre-fill phone if passed from login screen BEFORE adding listeners to avoid triggering updates during initialization
    if (widget.prefilledPhone != null && widget.prefilledPhone!.isNotEmpty) {
      _phoneCtrl.text = widget.prefilledPhone!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(registerProvider.notifier).setPhone(widget.prefilledPhone!);
        }
      });
    }

    // Sync controllers with notifier
    _nameCtrl.addListener(
        () => ref.read(registerProvider.notifier).setFullName(_nameCtrl.text));
    _emailCtrl.addListener(
        () => ref.read(registerProvider.notifier).setEmail(_emailCtrl.text));
    _phoneCtrl.addListener(
        () => ref.read(registerProvider.notifier).setPhone(_phoneCtrl.text));
    _cityCtrl.addListener(
        () => ref.read(registerProvider.notifier).setCity(_cityCtrl.text));
    _brandCtrl.addListener(() =>
        ref.read(registerProvider.notifier).setVehicleBrand(_brandCtrl.text));
    _modelCtrl.addListener(() =>
        ref.read(registerProvider.notifier).setVehicleModel(_modelCtrl.text));
    _yearCtrl.addListener(() =>
        ref.read(registerProvider.notifier).setVehicleYear(_yearCtrl.text));
    _numberCtrl.addListener(() =>
        ref.read(registerProvider.notifier).setVehicleNumber(_numberCtrl.text));
    _colorCtrl.addListener(() =>
        ref.read(registerProvider.notifier).setVehicleColor(_colorCtrl.text));
  }

  @override
  void dispose() {
    _entryController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _numberCtrl.dispose();
    _colorCtrl.dispose();
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

  void _handleNext() {
    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();
    final notifier = ref.read(registerProvider.notifier);
    final regState = ref.read(registerProvider);

    if (regState.currentStep == RegisterStep.otp) {
      _handleVerifyAndSubmit();
      return;
    }

    notifier.nextStep();
    _entryController.forward(from: 0);
  }

  void _handleBack() {
    HapticFeedback.lightImpact();
    final regState = ref.read(registerProvider);
    if (regState.currentStep == RegisterStep.personal) {
      context.pop();
      return;
    }
    ref.read(registerProvider.notifier).previousStep();
    _entryController.forward(from: 0);
  }

  Future<void> _handleVerifyAndSubmit() async {
    HapticFeedback.mediumImpact();
    final success =
        await ref.read(registerProvider.notifier).verifyOtpAndSubmit();
    if (success && mounted) {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    final regState = ref.watch(registerProvider);

    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background orbs
          Positioned(
            top: -60,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withAlpha(colors.isDark ? 20 : 12),
                    AppColors.primary.withAlpha(0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryAccent.withAlpha(colors.isDark ? 15 : 8),
                    AppColors.primaryAccent.withAlpha(0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _handleBack,
                        child: Container(
                          width: 40,
                          height: 40,
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
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          "Rider Registration",
                          style: AppTextStyles.headingSm.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      // Step indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(15),
                          borderRadius: AppRadius.pillAll,
                        ),
                        child: Text(
                          "${regState.stepIndex + 1}/${regState.totalSteps}",
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Step progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: List.generate(regState.totalSteps, (i) {
                      final isActive = i <= regState.stepIndex;
                      final isCurrent = i == regState.stepIndex;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: i == 0 ? 0 : 3,
                            right: i == regState.totalSteps - 1 ? 0 : 3,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: isCurrent ? 4 : 3,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primary
                                  : colors.divider,
                              borderRadius: AppRadius.pillAll,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: AppSpacing.xl,
                      right: AppSpacing.xl,
                      top: AppSpacing.lg,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 120,
                    ),
                    physics: const BouncingScrollPhysics(),
                    child: AnimatedBuilder(
                      animation: _entryController,
                      builder: (context, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Step header
                            FadeTransition(
                              opacity: _stagger(0),
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.15),
                                  end: Offset.zero,
                                ).animate(_stagger(0)),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primary.withAlpha(
                                                colors.isDark ? 40 : 25),
                                            AppColors.primaryAccent.withAlpha(
                                                colors.isDark ? 20 : 12),
                                          ],
                                        ),
                                        borderRadius: AppRadius.lgAll,
                                      ),
                                      child: Icon(
                                        regState.stepIcon,
                                        color: AppColors.primary,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            regState.stepTitle,
                                            style: AppTextStyles.headingSm
                                                .copyWith(
                                              color: colors.textPrimary,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            regState.stepSubtitle,
                                            style: AppTextStyles.caption
                                                .copyWith(
                                              color: colors.textTertiary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxl),

                            // Step content
                            FadeTransition(
                              opacity: _stagger(1),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 350),
                                switchInCurve: Curves.easeOut,
                                switchOutCurve: Curves.easeIn,
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.04, 0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
                                child: _buildStepContent(regState),
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
          ),

          // Bottom action bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                top: AppSpacing.lg,
                bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                color: colors.background,
                boxShadow: [
                  BoxShadow(
                    color: colors.cardShadow(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: (regState.isSubmitting || regState.isVerifyingOtp)
                    ? null
                    : _handleNext,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: regState.isSuccess
                        ? LinearGradient(
                            colors: [
                              AppColors.success,
                              AppColors.success.withAlpha(200),
                            ],
                          )
                        : const LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primaryAccent,
                            ],
                          ),
                    borderRadius: AppRadius.pillAll,
                    boxShadow: [
                      BoxShadow(
                        color: (regState.isSuccess
                                ? AppColors.success
                                : AppColors.primary)
                            .withAlpha(80),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: (regState.isSubmitting || regState.isVerifyingOtp)
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : regState.isSuccess
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_rounded,
                                      color: Colors.white, size: 22),
                                  SizedBox(width: AppSpacing.sm),
                                  Text(
                                    "Registration Complete!",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                regState.currentStep == RegisterStep.otp
                                    ? "Verify & Register"
                                    : "Continue",
                                style: AppTextStyles.buttonText.copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(RegisterState regState) {
    switch (regState.currentStep) {
      case RegisterStep.personal:
        return PersonalInfoCard(
          key: const ValueKey('personal'),
          nameController: _nameCtrl,
          emailController: _emailCtrl,
          phoneController: _phoneCtrl,
          cityController: _cityCtrl,
          dateOfBirth: regState.dateOfBirth,
          onDateOfBirthChanged: (value) =>
              ref.read(registerProvider.notifier).setDateOfBirth(value),
          errorMessage: regState.errorMessage.isNotEmpty
              ? regState.errorMessage
              : null,
        );
      case RegisterStep.vehicle:
        return VehicleInfoCard(
          key: const ValueKey('vehicle'),
          selectedType: regState.vehicleType,
          brandController: _brandCtrl,
          modelController: _modelCtrl,
          yearController: _yearCtrl,
          numberController: _numberCtrl,
          colorController: _colorCtrl,
          onTypeChanged: (type) =>
              ref.read(registerProvider.notifier).setVehicleType(type),
          errorMessage: regState.errorMessage.isNotEmpty
              ? regState.errorMessage
              : null,
        );
      case RegisterStep.documents:
        return DocumentUploadCard(
          key: const ValueKey('documents'),
          profilePhotoPath: regState.profilePhotoPath,
          drivingLicensePath: regState.drivingLicensePath,
          rcBookPath: regState.rcBookPath,
          insurancePath: regState.insurancePath,
          panCardPath: regState.panCardPath,
          aadharCardPath: regState.aadharCardPath,
          uploadedCount: regState.uploadedDocsCount,
          errorMessage: regState.errorMessage.isNotEmpty
              ? regState.errorMessage
              : null,
          onDocumentPicked: (docType, path) {
            final notifier = ref.read(registerProvider.notifier);
            switch (docType) {
              case 'profile':
                notifier.setProfilePhoto(path);
                break;
              case 'dl':
                notifier.setDrivingLicense(path);
                break;
              case 'rc':
                notifier.setRcBook(path);
                break;
              case 'insurance':
                notifier.setInsurance(path);
                break;
              case 'pan':
                notifier.setPanCard(path);
                break;
              case 'aadhar':
                notifier.setAadharCard(path);
                break;
            }
          },
          onDocumentRemoved: (docType) {
            ref.read(registerProvider.notifier).removeDocument(docType);
          },
        );
      case RegisterStep.otp:
        return _buildOtpStep(regState);
    }
  }

  Widget _buildOtpStep(RegisterState regState) {
    final colors = C.of(context);
    final notifier = ref.read(registerProvider.notifier);

    return Column(
      key: const ValueKey('otp'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Info text
        Text(
          "We've sent a 6-digit OTP to",
          style: AppTextStyles.bodySm.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          "+91 ${regState.maskedPhone}",
          style: AppTextStyles.headingSm.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        if (regState.isSendingOtp)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: CircularProgressIndicator(),
          )
        else ...[
          // OTP boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) {
              final isFilled = regState.otpDigits[i].isNotEmpty;
              final isNext = i == regState.filledOtpCount;
              return Container(
                width: 46,
                height: 56,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isFilled
                      ? AppColors.primary.withAlpha(15)
                      : colors.surfaceElevated,
                  borderRadius: AppRadius.lgAll,
                  border: Border.all(
                    color: isNext
                        ? AppColors.primary
                        : isFilled
                            ? AppColors.primary.withAlpha(60)
                            : colors.divider,
                    width: isNext ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    isFilled ? regState.otpDigits[i] : '',
                    style: AppTextStyles.headingMd.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              );
            }),
          ),

          if (regState.errorMessage.isNotEmpty) ...[
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.error, size: 16),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      regState.errorMessage,
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

          const SizedBox(height: AppSpacing.xxl),

          // Number pad
          _buildNumberPad(notifier),

          const SizedBox(height: AppSpacing.lg),

          // Resend
          GestureDetector(
            onTap: regState.isSendingOtp ? null : () => notifier.resendOtp(),
            child: Text(
              "Resend OTP",
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNumberPad(RegisterNotifier notifier) {
    final colors = C.of(context);
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];

    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            if (key.isEmpty) {
              return const SizedBox(width: 80, height: 56);
            }
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                if (key == 'del') {
                  notifier.deleteOtpDigit();
                } else {
                  notifier.setOtpDigit(key);
                }
              },
              child: Container(
                width: 80,
                height: 56,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  borderRadius: AppRadius.lgAll,
                ),
                child: Center(
                  child: key == 'del'
                      ? Icon(Icons.backspace_outlined,
                          color: colors.textSecondary, size: 22)
                      : Text(
                          key,
                          style: AppTextStyles.headingSm.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
