import 'package:bhukkdelivery/models/order_request.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MedicineTakeOrderCard extends StatelessWidget {
  final OrderRequest order;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const MedicineTakeOrderCard({
    super.key,
    required this.order,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return Container(
      decoration: colors.card,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.medicine.withAlpha(25),
                  borderRadius: AppRadius.mdAll,
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: AppColors.medicine,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.storeName,
                      style: AppTextStyles.headingSm.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${order.items} • ${order.distance}',
                      style: AppTextStyles.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${order.earnings.toStringAsFixed(0)}',
                    style: AppTextStyles.bodyLg.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${order.estimatedTime} min',
                    style: AppTextStyles.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surfaceOverlay,
              borderRadius: AppRadius.mdAll,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        order.pickupAddress,
                        style: AppTextStyles.bodySm.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.flag_rounded,
                      size: 16,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        order.dropAddress,
                        style: AppTextStyles.bodySm.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Payout Breakdown ──
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(colors.isDark ? 12 : 8),
              borderRadius: AppRadius.mdAll,
              border: Border.all(
                color: AppColors.primary.withAlpha(15),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _payoutChip('Base', '₹${order.baseFare.toStringAsFixed(0)}', colors),
                Container(height: 16, width: 0.5, color: colors.divider),
                _payoutChip('Distance', '₹${order.distanceFare.toStringAsFixed(0)}', colors),
                if (order.platformFee > 0) ...[
                  Container(height: 16, width: 0.5, color: colors.divider),
                  _payoutChip('Fee', '- ₹${order.platformFee.toStringAsFixed(0)}', colors, valueColor: AppColors.error),
                ],
                Container(height: 16, width: 0.5, color: colors.divider),
                _payoutChip('Total', '₹${order.earnings.toStringAsFixed(0)}', colors, valueColor: AppColors.success, isBold: true),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onDecline,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    decoration: AppButtonStyles.outlineButton(
                      borderColor: AppColors.error,
                    ),
                    child: Center(
                      child: Text(
                        'Decline',
                        style: AppTextStyles.buttonText.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: GestureDetector(
                  onTap: onAccept,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    decoration: AppButtonStyles.primaryButton,
                    child: Center(
                      child: Text(
                        'Accept',
                        style: AppTextStyles.buttonText.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _payoutChip(
    String label,
    String value,
    C colors, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.overline.copyWith(
            color: colors.textTertiary,
            fontSize: 8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            color: valueColor ?? colors.textPrimary,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
