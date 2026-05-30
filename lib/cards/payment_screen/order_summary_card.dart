import 'package:bhukkdelivery/providers/payment/payment_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Order summary breakdown — subtotal, delivery, taxes, discount, total.
class OrderSummaryCard extends ConsumerWidget {
  const OrderSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentProvider);
    final colors = C.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: colors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(colors.isDark ? 25 : 15),
                  borderRadius: AppRadius.mdAll,
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                "Order Summary",
                style: AppTextStyles.bodyLg.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  state.serviceType.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _SummaryRow(
            label: "Subtotal",
            value: "₹ ${state.subtotal.toStringAsFixed(0)}",
            colors: colors,
          ),
          const SizedBox(height: AppSpacing.md),
          _SummaryRow(
            label: "Delivery Fee",
            value: "₹ ${state.deliveryFee.toStringAsFixed(0)}",
            colors: colors,
          ),
          const SizedBox(height: AppSpacing.md),
          _SummaryRow(
            label: "Taxes & GST",
            value: "₹ ${state.taxes.toStringAsFixed(0)}",
            colors: colors,
          ),
          if (state.discount > 0) ...[
            const SizedBox(height: AppSpacing.md),
            _SummaryRow(
              label: "Discount",
              value: "- ₹ ${state.discount.toStringAsFixed(0)}",
              colors: colors,
              valueColor: AppColors.success,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.textTertiary.withAlpha(0),
                  colors.textTertiary.withAlpha(50),
                  colors.textTertiary.withAlpha(0),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total",
                style: AppTextStyles.bodyLg.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                "₹ ${state.totalAmount.toStringAsFixed(0)}",
                style: AppTextStyles.headingSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final C colors;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.colors,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySm.copyWith(color: colors.textSecondary),
        ),
        Text(
          value,
          style: AppTextStyles.bodySm.copyWith(
            color: valueColor ?? colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
