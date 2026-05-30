import 'package:bhukkdelivery/providers/profile/profile_provider.dart';
import 'package:bhukkdelivery/services/api/wallet_service.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom sheet with a bank details form for withdrawing earnings.
/// Auto-fills bank details from the driver's profile if previously saved.
class WithdrawBottomSheet extends ConsumerStatefulWidget {
  final double availableBalance;
  final UserProfile? profile;

  const WithdrawBottomSheet({
    super.key,
    required this.availableBalance,
    this.profile,
  });

  /// Show this bottom sheet from anywhere.
  static Future<void> show(
    BuildContext context,
    double availableBalance, {
    UserProfile? profile,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WithdrawBottomSheet(
        availableBalance: availableBalance,
        profile: profile,
      ),
    );
  }

  @override
  ConsumerState<WithdrawBottomSheet> createState() =>
      _WithdrawBottomSheetState();
}

enum _WithdrawStatus { idle, loading, success, error }

class _WithdrawBottomSheetState extends ConsumerState<WithdrawBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _holderController = TextEditingController();
  final _accountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _upiController = TextEditingController();

  _WithdrawStatus _status = _WithdrawStatus.idle;
  String _statusMessage = '';
  bool _isPreFilled = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.availableBalance.toStringAsFixed(0);

    // Auto-fill bank details from profile if available
    final profile = widget.profile;
    if (profile != null && profile.hasBankDetails) {
      _holderController.text = profile.bankAccountHolder ?? '';
      _accountController.text = profile.bankAccountNumber ?? '';
      _ifscController.text = profile.bankIfscCode ?? '';
      _upiController.text = profile.bankUpiId ?? '';
      _isPreFilled = true;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _holderController.dispose();
    _accountController.dispose();
    _ifscController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _handleWithdraw() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _status = _WithdrawStatus.loading);
    HapticFeedback.mediumImpact();

    try {
      final holder = _holderController.text.trim();
      final account = _accountController.text.trim();
      final ifsc = _ifscController.text.trim().toUpperCase();
      final upi = _upiController.text.trim();

      final result = await WalletService.requestWithdrawal(
        amount: double.parse(_amountController.text.trim()),
        accountHolder: holder,
        accountNumber: account,
        ifscCode: ifsc,
        upiId: upi.isNotEmpty ? upi : null,
      );

      final status = result['status']?.toString().toLowerCase() ?? '';
      if (status == 'error' || status == 'failed') {
        setState(() {
          _status = _WithdrawStatus.error;
          _statusMessage =
              result['message']?.toString() ?? 'Withdrawal failed.';
        });
      } else {
        // Save bank details to profile on successful withdrawal
        ref.read(profileProvider.notifier).updateProfile(
              bankAccountHolder: holder,
              bankAccountNumber: account,
              bankIfscCode: ifsc,
              bankUpiId: upi.isNotEmpty ? upi : null,
            );

        setState(() {
          _status = _WithdrawStatus.success;
          _statusMessage = result['message']?.toString() ??
              'Withdrawal request submitted!';
        });
      }
    } catch (e) {
      setState(() {
        _status = _WithdrawStatus.error;
        _statusMessage = e.toString().contains('403')
            ? 'Session expired. Please login again.'
            : e.toString().contains('400')
                ? 'Invalid details. Please check and retry.'
                : 'Something went wrong. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Drag handle ──
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.textTertiary.withAlpha(60),
                      borderRadius: AppRadius.pillAll,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Icon ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withAlpha(25),
                          AppColors.primary.withAlpha(10),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Title ──
                  Text(
                    'Withdraw Earnings',
                    style: AppTextStyles.headingSm.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Enter your bank details to transfer your earnings.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySm.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),

                  // ── Pre-filled indicator ──
                  if (_isPreFilled) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(15),
                        borderRadius: AppRadius.pillAll,
                        border: Border.all(
                          color: AppColors.success.withAlpha(40),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.success, size: 14),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Bank details loaded from profile',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Amount ──
                  _buildField(
                    controller: _amountController,
                    label: 'Amount (₹)',
                    hint: 'Enter amount',
                    icon: Icons.currency_rupee_rounded,
                    colors: colors,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      final amt = double.tryParse(v);
                      if (amt == null || amt <= 0) return 'Enter a valid amount';
                      if (amt > widget.availableBalance) {
                        return 'Max ₹${widget.availableBalance.toStringAsFixed(0)}';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Account Holder Name ──
                  _buildField(
                    controller: _holderController,
                    label: 'Account Holder Name',
                    hint: 'As per bank records',
                    icon: Icons.person_outline_rounded,
                    colors: colors,
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Account Number ──
                  _buildField(
                    controller: _accountController,
                    label: 'Account Number',
                    hint: 'Enter account number',
                    icon: Icons.credit_card_rounded,
                    colors: colors,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (v.trim().length < 8) return 'Invalid account number';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── IFSC Code ──
                  _buildField(
                    controller: _ifscController,
                    label: 'IFSC Code',
                    hint: 'e.g. SBIN0001234',
                    icon: Icons.account_balance_rounded,
                    colors: colors,
                    textCapitalization: TextCapitalization.characters,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      // Standard IFSC: 4 letters + 7 alphanumeric
                      if (!RegExp(r'^[A-Z]{4}[0-9A-Z]{7}$')
                          .hasMatch(v.trim().toUpperCase())) {
                        return 'Invalid IFSC code';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── UPI ID (Optional) ──
                  _buildField(
                    controller: _upiController,
                    label: 'UPI ID (Optional)',
                    hint: 'yourname@upi',
                    icon: Icons.qr_code_2_rounded,
                    colors: colors,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Status messages ──
                  if (_status == _WithdrawStatus.error) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(15),
                        borderRadius: AppRadius.mdAll,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.error, size: 18),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              _statusMessage,
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (_status == _WithdrawStatus.success) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(15),
                        borderRadius: AppRadius.mdAll,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              color: AppColors.success, size: 18),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              _statusMessage,
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.success),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ── Submit button ──
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _status == _WithdrawStatus.success
                            ? AppColors.success
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.pillAll),
                      ),
                      onPressed: _status == _WithdrawStatus.loading
                          ? null
                          : _status == _WithdrawStatus.success
                              ? () => Navigator.pop(context)
                              : _handleWithdraw,
                      icon: _status == _WithdrawStatus.loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              _status == _WithdrawStatus.success
                                  ? Icons.done_rounded
                                  : Icons.send_rounded,
                              size: 20,
                            ),
                      label: Text(
                        _status == _WithdrawStatus.loading
                            ? 'Processing...'
                            : _status == _WithdrawStatus.success
                                ? 'Done'
                                : 'Withdraw to Bank',
                        style: AppTextStyles.bodyLg.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // ── Security note ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shield_outlined,
                          size: 12, color: colors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        'Bank details are encrypted & secure',
                        style: AppTextStyles.overline.copyWith(
                          color: colors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required C colors,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          validator: validator,
          style: AppTextStyles.bodyMd.copyWith(color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                AppTextStyles.bodySm.copyWith(color: colors.textTertiary),
            prefixIcon: Icon(icon,
                size: 20, color: AppColors.primary.withAlpha(180)),
            filled: true,
            fillColor: colors.blush.withAlpha(colors.isDark ? 15 : 40),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
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
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.lgAll,
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}
