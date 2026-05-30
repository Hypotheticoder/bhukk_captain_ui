import 'package:bhukkdelivery/notifiers/payment_screen/payment_notifier.dart';
import 'package:bhukkdelivery/providers/payment/payment_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The "Pay Now" / "Confirm COD" button with animated state transitions.
class PayButtonCard extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;

  const PayButtonCard({super.key, required this.onSuccess});

  @override
  ConsumerState<PayButtonCard> createState() => _PayButtonCardState();
}

class _PayButtonCardState extends ConsumerState<PayButtonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentProvider);
    final colors = C.of(context);

    final isCod = state.selectedMethod == PaymentMethodType.cashOnDelivery;
    final isProcessing = state.status == PaymentStatus.processing;
    final isSuccess = state.status == PaymentStatus.success;
    final canProceed = state.canProceed;

    ref.listen<PaymentState>(paymentProvider, (prev, next) {
      if (next.status == PaymentStatus.success) {
        widget.onSuccess();
      }
    });

    return Column(
      children: [
        // ── Security badge ──
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_rounded,
              size: 13,
              color: colors.textTertiary,
            ),
            const SizedBox(width: 4),
            Text(
              "Secure Transaction  •  Razorpay Powered",
              style: AppTextStyles.caption.copyWith(
                color: colors.textTertiary,
                fontSize: 10,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Pay button ──
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final glowOpacity =
                canProceed && !isProcessing ? _pulseController.value * 0.3 : 0.0;

            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: AppRadius.lgAll,
                boxShadow: canProceed && !isProcessing
                    ? [
                        BoxShadow(
                          color:
                              AppColors.primary.withAlpha((glowOpacity * 255).toInt()),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: child,
            );
          },
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: canProceed && !isProcessing && !isSuccess
                  ? () => ref.read(paymentProvider.notifier).processPayment()
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isSuccess ? AppColors.success : AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: colors.textTertiary.withAlpha(40),
                disabledForegroundColor: colors.textTertiary,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.lgAll,
                ),
                elevation: 0,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isProcessing
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : isSuccess
                        ? Row(
                            key: const ValueKey('success'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                "Payment Collected!",
                                style: AppTextStyles.bodyLg.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            key: const ValueKey('pay'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isCod
                                    ? Icons.delivery_dining_rounded
                                    : Icons.payment_rounded,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                canProceed
                                    ? isCod
                                        ? "Confirm Cash Collection"
                                        : "Collect ₹ ${state.totalAmount.toStringAsFixed(0)} via UPI"
                                    : "Select a payment method",
                                style: AppTextStyles.bodyLg.copyWith(
                                  color:
                                      canProceed ? Colors.white : colors.textTertiary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
