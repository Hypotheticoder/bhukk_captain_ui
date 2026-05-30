import 'package:bhukkdelivery/notifiers/payment_screen/payment_notifier.dart';
import 'package:bhukkdelivery/providers/payment/payment_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Shows a scannable UPI QR code when the driver selects UPI payment.
/// The customer scans this to pay.
class UpiQrCard extends ConsumerStatefulWidget {
  const UpiQrCard({super.key});

  @override
  ConsumerState<UpiQrCard> createState() => _UpiQrCardState();
}

class _UpiQrCardState extends ConsumerState<UpiQrCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Build a UPI deep-link string for QR generation.
  /// Format: upi://pay?pa=VPA&pn=NAME&am=AMOUNT&cu=INR&tn=NOTE
  String _buildUpiUri(PaymentState state) {
    // In production, replace with your merchant UPI VPA
    const merchantVpa = 'bhukkdelivery@upi';
    const merchantName = 'Caby24 Delivery';
    final amount = state.totalAmount.toStringAsFixed(2);
    final note = 'Order ${state.orderId}';

    return 'upi://pay?pa=$merchantVpa'
        '&pn=${Uri.encodeComponent(merchantName)}'
        '&am=$amount'
        '&cu=INR'
        '&tn=${Uri.encodeComponent(note)}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentProvider);
    final colors = C.of(context);

    // Only show when UPI/QR is selected
    if (state.selectedMethod != PaymentMethodType.upiQr) {
      return const SizedBox.shrink();
    }

    final upiUri = _buildUpiUri(state);

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glowAlpha = (30 + (_pulseController.value * 25)).toInt();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.xlAll,
            border: Border.all(
              color: const Color(0xFF6366F1).withAlpha(60),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withAlpha(glowAlpha),
                blurRadius: 20,
                offset: const Offset(0, 6),
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.qr_code_scanner_rounded,
                color: Color(0xFF6366F1),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Ask customer to scan",
                style: AppTextStyles.bodyLg.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            "Show this QR code to the customer",
            style: AppTextStyles.caption.copyWith(
              color: colors.textTertiary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // QR Code
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.lgAll,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: QrImageView(
              data: upiUri,
              version: QrVersions.auto,
              size: 200,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF1E1E2E),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF1E1E2E),
              ),
              embeddedImage: null,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Amount badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6366F1).withAlpha(15),
                  const Color(0xFF8B5CF6).withAlpha(10),
                ],
              ),
              borderRadius: AppRadius.pillAll,
              border: Border.all(
                color: const Color(0xFF6366F1).withAlpha(40),
              ),
            ),
            child: Text(
              "₹ ${state.totalAmount.toStringAsFixed(0)}",
              style: AppTextStyles.headingSm.copyWith(
                color: const Color(0xFF6366F1),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Supported apps
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _appChip("GPay", colors),
              const SizedBox(width: AppSpacing.sm),
              _appChip("PhonePe", colors),
              const SizedBox(width: AppSpacing.sm),
              _appChip("Paytm", colors),
              const SizedBox(width: AppSpacing.sm),
              _appChip("Any UPI", colors),
            ],
          ),
        ],
      ),
    );
  }

  Widget _appChip(String label, C colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.textTertiary.withAlpha(15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: colors.textSecondary,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
