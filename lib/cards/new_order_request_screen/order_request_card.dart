import 'package:bhukkdelivery/providers/new_order/new_order_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';

class OrderRequestCard extends StatelessWidget {
  final OrderRequest order;

  const OrderRequestCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return Container(
      width: double.infinity,
      decoration: colors.accentBorderedCard,
      child: Column(
        children: [
          // Top accent bar
          Container(
            height: 5,
            width: 80,
            margin: const EdgeInsets.only(top: AppSpacing.md),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryAccent],
              ),
              borderRadius: AppRadius.pillAll,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                // Order ID + payment method
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.orderId,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: colors.textSecondary,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm + 2,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.info.withAlpha(colors.isDark ? 30 : 15),
                        borderRadius: AppRadius.pillAll,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.payment_rounded,
                            size: 12,
                            color: AppColors.info,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.paymentMethod,
                            style: AppTextStyles.overline.copyWith(
                              color: AppColors.info,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // Restaurant name + cuisine + rating
                Text(
                  order.storeName,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headingMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${order.cuisineType} • ",
                      style: AppTextStyles.label.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                    Icon(Icons.star_rounded, size: 14, color: AppColors.starYellow),
                    const SizedBox(width: 2),
                    Text(
                      order.restaurantRating.toStringAsFixed(1),
                      style: AppTextStyles.label.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Route visualization
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: colors.blush.withAlpha(colors.isDark ? 20 : 50),
                    borderRadius: AppRadius.lgAll,
                  ),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.success,
                              border: Border.all(
                                  color: AppColors.success.withAlpha(80),
                                  width: 2),
                            ),
                          ),
                          Container(
                            width: 1.5,
                            height: 24,
                            margin: const EdgeInsets.symmetric(
                                vertical: AppSpacing.xs),
                            color: colors.divider,
                          ),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.error,
                              border: Border.all(
                                  color: AppColors.error.withAlpha(80),
                                  width: 2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.pickupAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(
                                color: colors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg + 4),
                            Text(
                              order.dropAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(
                                color: colors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Stats row
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                    horizontal: AppSpacing.lg,
                  ),
                  decoration: colors.infoRow,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(
                        Icons.location_on_rounded,
                        order.distance,
                        "Distance",
                        AppColors.primary,
                        colors,
                      ),
                      _buildDivider(colors),
                      _buildStat(
                        Icons.timer_outlined,
                        "${order.estimatedTime} min",
                        "Est. Time",
                        AppColors.warning,
                        colors,
                      ),
                      _buildDivider(colors),
                      _buildStat(
                        Icons.shopping_bag_outlined,
                        "${order.itemCount}",
                        "Items",
                        AppColors.info,
                        colors,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Payout Breakdown (Redesigned)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated.withAlpha(colors.isDark ? 80 : 150),
                    borderRadius: AppRadius.lgAll,
                    border: Border.all(
                      color: AppColors.primary.withAlpha(30),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(10),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Base Fare",
                            style: AppTextStyles.bodyMd.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          Text(
                            "₹${order.baseFare.toStringAsFixed(2)}",
                            style: AppTextStyles.bodyMd.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Distance Fare",
                            style: AppTextStyles.bodyMd.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          Text(
                            "₹${order.distanceFare.toStringAsFixed(2)}",
                            style: AppTextStyles.bodyMd.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (order.platformFee > 0) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Platform Fee",
                              style: AppTextStyles.bodyMd.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                            Text(
                              "- ₹${order.platformFee.toStringAsFixed(2)}",
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: Divider(
                          color: colors.divider.withAlpha(100),
                          height: 1,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ESTIMATED EARNINGS",
                                style: AppTextStyles.overline.copyWith(
                                  letterSpacing: 1.5,
                                  color: AppColors.primaryAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Includes all surges",
                                style: AppTextStyles.label.copyWith(
                                  color: colors.textTertiary,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "₹${order.earnings.toStringAsFixed(2)}",
                            style: AppTextStyles.headingLg.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w800,
                              shadows: [
                                Shadow(
                                  color: AppColors.primary.withAlpha(50),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
    IconData icon,
    String value,
    String label,
    Color color,
    C colors,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.bodyMd.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.textPrimary.withAlpha(222),
          ),
        ),
        Text(
          label,
          style: AppTextStyles.overline.copyWith(color: colors.textTertiary),
        ),
      ],
    );
  }

  Widget _buildDivider(C colors) {
    return Container(
      height: 30,
      width: 1,
      color: colors.textTertiary.withAlpha(77),
    );
  }
}
