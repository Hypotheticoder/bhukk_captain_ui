import 'package:bhukkdelivery/models/order_request.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';

class PayoutBreakdownCard extends StatelessWidget {
  final OrderRequest order;

  const PayoutBreakdownCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    final distanceKm = _parseDistanceKm(order.distance);
    final perKmRate = distanceKm > 0 ? (order.distanceFare / distanceKm) : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceElevated.withAlpha(colors.isDark ? 80 : 140),
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.primary.withAlpha(20), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: AppRadius.smAll,
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                "Payment Details",
                style: AppTextStyles.bodyLg.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              // Payment Method Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.purple.withAlpha(20),
                  borderRadius: AppRadius.smAll,
                  border: Border.all(color: AppColors.purple.withAlpha(40)),
                ),
                child: Text(
                  order.paymentMethod.toUpperCase(),
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.purple,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: colors.divider.withAlpha(40), height: 1),
          const SizedBox(height: AppSpacing.md),

          // 1. What the customer is paying in total
          if (order.customerOrderAmount > 0) ...[
            _buildRow(
              'Customer Total Bill',
              '₹${order.customerOrderAmount.toStringAsFixed(0)}',
              colors.textSecondary,
              colors.textPrimary,
              isBold: true,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          // 2. The Fares
          _buildRow(
            'Incentive',
            '₹${order.baseFare.toStringAsFixed(0)}',
            colors.textSecondary,
            colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildRow(
            'Per km charge',
            '₹${perKmRate.toStringAsFixed(0)} × ${distanceKm.toStringAsFixed(2)} km',
            colors.textTertiary,
            colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildRow(
            'Total(roundup)',
            '₹${order.distanceFare.toStringAsFixed(2)} (₹${order.distanceFare.toStringAsFixed(0)})',
            colors.textSecondary,
            colors.textSecondary,
          ),

          // 3. What you are taking from them (Red)
          const SizedBox(height: AppSpacing.xs),
          _buildRow(
            'Platform Fee (taken)',
            '- ₹${order.platformFee.toStringAsFixed(2)}',
            colors.textSecondary,
            AppColors.error,
          ),

          const SizedBox(height: AppSpacing.md),
          Divider(color: colors.divider.withAlpha(40), height: 1),
          const SizedBox(height: AppSpacing.md),

          // 4. Net payout (Massive & Green)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'YOUR EARNINGS',
                style: AppTextStyles.overline.copyWith(
                  letterSpacing: 1.2,
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              Text(
                '₹${order.earnings.toStringAsFixed(0)}',
                style: AppTextStyles.headingMd.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.success,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _parseDistanceKm(String distanceText) {
    final text = distanceText.toLowerCase().replaceAll('km', '').trim();
    final value = double.tryParse(text);
    return value ?? 0.0;
  }

  Widget _buildRow(
    String label,
    String value,
    Color labelColor,
    Color valueColor, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: labelColor,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMd.copyWith(
            color: valueColor,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
