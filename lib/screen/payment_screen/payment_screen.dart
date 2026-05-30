import 'package:bhukkdelivery/cards/payment_screen/order_summary_card.dart';
import 'package:bhukkdelivery/cards/payment_screen/pay_button_card.dart';
import 'package:bhukkdelivery/cards/payment_screen/payment_method_card.dart';
import 'package:bhukkdelivery/cards/payment_screen/upi_qr_card.dart';
import 'package:bhukkdelivery/providers/payment/payment_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  /// The service type — used to disable COD for liquor/beverages.
  final String serviceType;

  /// The order amount (subtotal).
  final double amount;

  /// An optional order ID for tracking.
  final String orderId;

  const PaymentScreen({
    super.key,
    required this.serviceType,
    required this.amount,
    this.orderId = 'ORD-001',
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    // Initialize payment state after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentProvider.notifier).initPayment(
            orderId: widget.orderId,
            serviceType: widget.serviceType,
            amount: widget.amount,
          );
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Animation<double> _staggeredFade(int index) {
    final start = (index * 0.10).clamp(0.0, 0.7);
    final end = (start + 0.3).clamp(0.0, 1.0);
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  Animation<Offset> _staggeredSlide(int index) {
    final start = (index * 0.10).clamp(0.0, 0.7);
    final end = (start + 0.3).clamp(0.0, 1.0);
    return Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    final sections = <Widget>[
      // ── 0. Header ──
      _PaymentHeader(colors: colors),

      // ── 1. Order summary ──
      const OrderSummaryCard(),

      // ── 2. Payment methods ──
      const PaymentMethodCard(),

      // ── 3. UPI QR code (visible only when UPI is selected) ──
      const UpiQrCard(),

      // ── 4. Pay button ──
      PayButtonCard(
        onSuccess: () {
          final navigator = GoRouter.of(context);
          // Show success & navigate back after a short delay
          Future.delayed(const Duration(milliseconds: 1200), () {
            if (mounted) {
              ref.read(paymentProvider.notifier).resetPayment();
              navigator.pop(); // Pop back to navigation screen to enter the 2nd OTP!
            }
          });
        },
      ),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: colors.textPrimary,
                      size: 20,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.surface,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.mdAll,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withAlpha(20),
                          AppColors.secondary.withAlpha(15),
                        ],
                      ),
                      borderRadius: AppRadius.pillAll,
                      border: Border.all(
                        color: AppColors.primary.withAlpha(40),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.shield_rounded,
                          color: AppColors.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Secure Payment",
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48), // balance the back button
                ],
              ),
            ),

            // ── Scrollable content ──
            Expanded(
              child: AnimatedBuilder(
                animation: _staggerController,
                builder: (context, _) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < sections.length; i++) ...[
                          SlideTransition(
                            position: _staggeredSlide(i),
                            child: FadeTransition(
                              opacity: _staggeredFade(i),
                              child: sections[i],
                            ),
                          ),
                          SizedBox(
                            height:
                                i < sections.length - 1 ? AppSpacing.xxl : 0,
                          ),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The hero header with a gradient icon and title.
class _PaymentHeader extends StatelessWidget {
  final C colors;

  const _PaymentHeader({required this.colors});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          // Gradient icon circle
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(50),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.payment_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          "Collect Payment",
          style: AppTextStyles.headingMd.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          "How would the customer like to pay?",
          style: AppTextStyles.bodySm.copyWith(
            color: colors.textTertiary,
          ),
        ),
      ],
    ));
  }
}
