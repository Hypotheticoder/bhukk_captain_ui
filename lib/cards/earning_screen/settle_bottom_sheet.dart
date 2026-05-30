import 'package:bhukkdelivery/services/api/wallet_service.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payu_checkoutpro_flutter/payu_checkoutpro_flutter.dart';
import 'package:payu_checkoutpro_flutter/PayUConstantKeys.dart';

/// Bottom sheet for settling commission owed via PayU gateway.
/// Shows a full breakdown then launches PayU Checkout Pro SDK.
class SettleBottomSheet extends StatefulWidget {
  final double amountOwed;
  final double cashInHand;
  final double commissionOwed;
  final double todayEarnings;
  final double rideEarnings;
  final double parcelEarnings;
  final double codEarnings;
  final double onlineEarnings;
  final String driverPhone;
  final String driverEmail;

  const SettleBottomSheet({
    super.key,
    required this.amountOwed,
    this.cashInHand = 0,
    this.commissionOwed = 0,
    this.todayEarnings = 0,
    this.rideEarnings = 0,
    this.parcelEarnings = 0,
    this.codEarnings = 0,
    this.onlineEarnings = 0,
    this.driverPhone = '',
    this.driverEmail = '',
  });

  static Future<void> show(
    BuildContext context, {
    required double amountOwed,
    double cashInHand = 0,
    double commissionOwed = 0,
    double todayEarnings = 0,
    double rideEarnings = 0,
    double parcelEarnings = 0,
    double codEarnings = 0,
    double onlineEarnings = 0,
    String driverPhone = '',
    String driverEmail = '',
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SettleBottomSheet(
        amountOwed: amountOwed,
        cashInHand: cashInHand,
        commissionOwed: commissionOwed,
        todayEarnings: todayEarnings,
        rideEarnings: rideEarnings,
        parcelEarnings: parcelEarnings,
        codEarnings: codEarnings,
        onlineEarnings: onlineEarnings,
        driverPhone: driverPhone,
        driverEmail: driverEmail,
      ),
    );
  }

  @override
  State<SettleBottomSheet> createState() => _SettleBottomSheetState();
}

enum _SettleStatus { idle, loading, success, error }

class _SettleBottomSheetState extends State<SettleBottomSheet>
    implements PayUCheckoutProProtocol {
  _SettleStatus _status = _SettleStatus.idle;
  String _statusMessage = '';
  late PayUCheckoutProFlutter _checkoutPro;

  @override
  void initState() {
    super.initState();
    _checkoutPro = PayUCheckoutProFlutter(this);
  }

  // ─── PayU Checkout Pro SDK Flow ───

  Future<void> _handleSettle() async {
    setState(() {
      _status = _SettleStatus.loading;
      _statusMessage = '';
    });
    HapticFeedback.mediumImpact();

    try {
      // Step 1: Call /initiate to get PayU params from backend
      final payuData =
          await WalletService.initiateSettlement(widget.amountOwed);

      if (payuData.isEmpty) {
        setState(() {
          _status = _SettleStatus.error;
          _statusMessage = 'Failed to initiate payment. Try again.';
        });
        return;
      }

      debugPrint('[SettleSheet] PayU initiate data: $payuData');

      // Step 2: Build payment params for PayU SDK
      // Using the exact strings from backend as requested
      final paymentParams = <String, dynamic>{
        PayUPaymentParamKey.key:
            payuData['key']?.toString() ?? '',
        PayUPaymentParamKey.transactionId:
            payuData['txnid']?.toString() ??
            payuData['transaction_id']?.toString() ?? '',
        PayUPaymentParamKey.amount:
            payuData['amount']?.toString() ?? widget.amountOwed.toString(), // Strict string passing
        PayUPaymentParamKey.productInfo:
            payuData['productinfo']?.toString() ??
            payuData['product_info']?.toString() ?? 'Commission Settlement',
        PayUPaymentParamKey.firstName:
            payuData['firstname']?.toString() ??
            payuData['first_name']?.toString() ?? 'Driver',
        PayUPaymentParamKey.email:
            payuData['email']?.toString().isNotEmpty == true
                ? payuData['email'].toString()
                : widget.driverEmail,
        PayUPaymentParamKey.phone:
            _sanitizePhone(
              payuData['phone']?.toString().isNotEmpty == true
                  ? payuData['phone'].toString()
                  : widget.driverPhone,
            ),
        PayUPaymentParamKey.environment: '0', // 🚨 Switched to "0" (Production)
        PayUPaymentParamKey.android_surl:
            payuData['surl']?.toString() ??
            payuData['success_url']?.toString() ?? '',
        PayUPaymentParamKey.android_furl:
            payuData['furl']?.toString() ??
            payuData['failure_url']?.toString() ?? '',
        PayUPaymentParamKey.ios_surl:
            payuData['surl']?.toString() ??
            payuData['success_url']?.toString() ?? '',
        PayUPaymentParamKey.ios_furl:
            payuData['furl']?.toString() ??
            payuData['failure_url']?.toString() ?? '',
        PayUPaymentParamKey.userCredential:
            payuData['user_credential']?.toString() ??
            payuData['userCredential']?.toString() ?? '',
      };

      // Handle Hash in additionalParams
      final additionalParams = <String, dynamic>{};
      
      if (payuData['hash'] != null) {
        additionalParams['payment_related_details_for_mobile_sdk'] = payuData['hash'].toString();
      }

      if (additionalParams.isNotEmpty) {
        paymentParams[PayUPaymentParamKey.additionalParam] = additionalParams;
      }

      // Step 3: Launch PayU Checkout Pro SDK
      _checkoutPro.openCheckoutScreen(
        payUPaymentParams: paymentParams,
        payUCheckoutProConfig: _buildConfig(),
      );
    } catch (e) {
      debugPrint('[SettleSheet] Error: $e');
      setState(() {
        _status = _SettleStatus.error;
        _statusMessage = e.toString().contains('403')
            ? 'Session expired. Please login again.'
            : 'Settlement failed. Please try again.';
      });
    }
  }

  Map<String, dynamic> _buildConfig() {
    return {
      PayUCheckoutProConfigKeys.primaryColor: '#0D1B2A',
      PayUCheckoutProConfigKeys.secondaryColor: '#00E5B0',
      PayUCheckoutProConfigKeys.merchantName: 'Bhukk',
      PayUCheckoutProConfigKeys.showExitConfirmationOnCheckoutScreen: true,
      PayUCheckoutProConfigKeys.showExitConfirmationOnPaymentScreen: true,
    };
  }

  /// Strips country code prefix (+91, 91, 0) to get a raw 10-digit number.
  String _sanitizePhone(String raw) {
    // Remove all non-digit characters
    String digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    // Strip leading country code
    if (digits.length > 10) {
      if (digits.startsWith('91')) {
        digits = digits.substring(2);
      } else if (digits.startsWith('0')) {
        digits = digits.substring(1);
      }
    }
    // Take last 10 digits as a final safety net
    if (digits.length > 10) {
      digits = digits.substring(digits.length - 10);
    }
    return digits;
  }

  // ─── PayUCheckoutProProtocol callbacks ───

  @override
  generateHash(Map response) async {
    // The SDK asks for a hash — forward to backend
    debugPrint('[SettleSheet] generateHash called for: ${response['hashName']}');
    try {
      final hashMap = await WalletService.generateHash(
        Map<String, dynamic>.from(response),
      );
      
      if (hashMap.isNotEmpty) {
        // Give it back to PayU so it can unlock the screen!
        _checkoutPro.hashGenerated(hash: hashMap);
      }
    } catch (e) {
      debugPrint('[SettleSheet] Hash generation failed: $e');
    }
  }

  @override
  onPaymentSuccess(dynamic response) {
    debugPrint('[SettleSheet] Payment Success: $response');
    if (mounted) {
      setState(() {
        _status = _SettleStatus.success;
        _statusMessage = 'Payment successful! Your commission has been settled.';
      });
    }
  }

  @override
  onPaymentFailure(dynamic response) {
    debugPrint('[SettleSheet] Payment Failed: $response');
    if (mounted) {
      setState(() {
        _status = _SettleStatus.error;
        _statusMessage = 'Payment failed. Please try again.';
      });
    }
  }

  @override
  onPaymentCancel(Map? response) {
    debugPrint('[SettleSheet] Payment Cancelled: $response');
    if (mounted) {
      setState(() {
        _status = _SettleStatus.idle;
        _statusMessage = '';
      });
    }
  }

  @override
  onError(Map? response) {
    debugPrint('[SettleSheet] SDK Error: $response');
    if (mounted) {
      setState(() {
        _status = _SettleStatus.error;
        _statusMessage = response?['errorMsg']?.toString() ?? 'An error occurred.';
      });
    }
  }

  // ─── UI ───

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl,
          ),
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
              const SizedBox(height: AppSpacing.lg),

              // ── Header ──
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(colors.isDark ? 25 : 15),
                      borderRadius: AppRadius.mdAll,
                    ),
                    child: const Icon(
                      Icons.account_balance_rounded,
                      color: AppColors.error,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Settle Commission',
                          style: AppTextStyles.bodyLg.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pay via PayU Payment Gateway',
                          style: AppTextStyles.caption.copyWith(
                            color: colors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Breakdown Card ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: colors.blush.withAlpha(colors.isDark ? 15 : 40),
                  borderRadius: AppRadius.xlAll,
                  border: Border.all(
                    color: colors.divider.withAlpha(50),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    _breakdownRow(
                      'Total Earnings', '₹${widget.todayEarnings.toStringAsFixed(0)}',
                      colors.textSecondary, colors.textPrimary, colors,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (widget.rideEarnings > 0) ...[
                      _breakdownRow(
                        '  Ride Earnings', '₹${widget.rideEarnings.toStringAsFixed(0)}',
                        colors.textTertiary, colors.textSecondary, colors,
                        icon: Icons.directions_car_rounded, iconColor: AppColors.carBooking,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ],
                    if (widget.parcelEarnings > 0) ...[
                      _breakdownRow(
                        '  Parcel Earnings', '₹${widget.parcelEarnings.toStringAsFixed(0)}',
                        colors.textTertiary, colors.textSecondary, colors,
                        icon: Icons.inventory_2_rounded, iconColor: AppColors.parcel,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    Divider(color: colors.divider.withAlpha(60), height: 1),
                    const SizedBox(height: AppSpacing.sm),
                    _breakdownRow(
                      'Cash (COD) Collected', '₹${widget.codEarnings.toStringAsFixed(0)}',
                      colors.textSecondary, AppColors.warning, colors,
                      icon: Icons.payments_rounded, iconColor: AppColors.warning,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _breakdownRow(
                      'Online Payments', '₹${widget.onlineEarnings.toStringAsFixed(0)}',
                      colors.textSecondary, colors.textSecondary, colors,
                      icon: Icons.credit_card_rounded, iconColor: AppColors.primary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Divider(color: colors.divider.withAlpha(60), height: 1),
                    const SizedBox(height: AppSpacing.sm),
                    _breakdownRow(
                      'Cash In Hand', '₹${widget.cashInHand.toStringAsFixed(0)}',
                      colors.textSecondary, colors.textPrimary, colors, isBold: true,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _breakdownRow(
                      'Platform Commission', '- ₹${widget.commissionOwed.toStringAsFixed(0)}',
                      colors.textSecondary, AppColors.error, colors, isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Total To Pay ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppColors.error.withAlpha(colors.isDark ? 25 : 12),
                    AppColors.error.withAlpha(colors.isDark ? 15 : 6),
                  ]),
                  borderRadius: AppRadius.xlAll,
                  border: Border.all(
                    color: AppColors.error.withAlpha(40),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AMOUNT TO SETTLE',
                      style: AppTextStyles.overline.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '₹ ${widget.amountOwed.toStringAsFixed(0)}',
                      style: AppTextStyles.headingSm.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Status messages ──
              if (_status == _SettleStatus.error) ...[
                _statusBanner(
                  Icons.error_outline, AppColors.error, _statusMessage,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (_status == _SettleStatus.success) ...[
                _statusBanner(
                  Icons.check_circle_outline, AppColors.success, _statusMessage,
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // ── Button ──
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _status == _SettleStatus.success
                        ? AppColors.success
                        : AppColors.error,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.pillAll,
                    ),
                  ),
                  onPressed: _status == _SettleStatus.loading
                      ? null
                      : _status == _SettleStatus.success
                          ? () => Navigator.pop(context)
                          : _handleSettle,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_status == _SettleStatus.loading)
                        const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white,
                          ),
                        )
                      else
                        Icon(
                          _status == _SettleStatus.success
                              ? Icons.done_rounded
                              : Icons.payment_rounded,
                          size: 20, color: Colors.white,
                        ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _status == _SettleStatus.loading
                            ? 'Initiating...'
                            : _status == _SettleStatus.success
                                ? 'Done'
                                : 'Pay ₹${widget.amountOwed.toStringAsFixed(0)} via PayU',
                        style: AppTextStyles.bodyLg.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Security note ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 12, color: colors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    'Secured by PayU Payment Gateway',
                    style: AppTextStyles.overline.copyWith(
                      color: colors.textTertiary, fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBanner(IconData icon, Color color, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message,
                style: AppTextStyles.caption.copyWith(color: color)),
          ),
        ],
      ),
    );
  }

  Widget _breakdownRow(
    String label, String value, Color labelColor, Color valueColor, C colors, {
    bool isBold = false, IconData? icon, Color? iconColor,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: iconColor ?? labelColor),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(label, style: AppTextStyles.bodySm.copyWith(
            color: labelColor,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          )),
        ),
        Text(value, style: AppTextStyles.bodySm.copyWith(
          color: valueColor,
          fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          fontSize: 13,
        )),
      ],
    );
  }
}
