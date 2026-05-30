import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ActiveOrderCard extends ConsumerStatefulWidget {
  const ActiveOrderCard({super.key});

  @override
  ConsumerState<ActiveOrderCard> createState() => _ActiveOrderCardState();
}

class _ActiveOrderCardState extends ConsumerState<ActiveOrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _tiltController;
  late Animation<double> _tiltAnim;

  @override
  void initState() {
    super.initState();
    _tiltController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _tiltAnim = Tween<double>(begin: -0.015, end: 0.015).animate(
      CurvedAnimation(parent: _tiltController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tiltController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    final delivery = ref.watch(activeDeliveryProvider);

    return AnimatedBuilder(
      animation: _tiltAnim,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_tiltAnim.value)
            ..rotateX(_tiltAnim.value * 0.5),
          child: delivery != null
              ? _buildActiveCard(context, colors, delivery)
              : _buildEmptyCard(colors),
        );
      },
    );
  }

  /// Shows the current active delivery details
  Widget _buildActiveCard(
    BuildContext context,
    C colors,
    ActiveDelivery delivery,
  ) {
    final isPickup = delivery.isPickupPhase;

    return GestureDetector(
      onTap: () {
        final currentPath = GoRouterState.of(context).uri.path;
        if (!currentPath.startsWith('/home/live_navigation')) {
          context.push('/home/live_navigation');
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: AppRadius.xlAll,
          border: Border.all(
            color: (isPickup ? AppColors.warning : AppColors.primary).withAlpha(
              colors.isDark ? 60 : 40,
            ),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.cardShadow(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            // Status badge row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs + 1,
                  ),
                  decoration: BoxDecoration(
                    color: (isPickup ? AppColors.warning : AppColors.success)
                        .withAlpha(colors.isDark ? 30 : 15),
                    borderRadius: AppRadius.pillAll,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isPickup
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        delivery.statusLabel,
                        style: AppTextStyles.caption.copyWith(
                          color: isPickup
                              ? AppColors.warning
                              : AppColors.success,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  delivery.orderId,
                  style: AppTextStyles.caption.copyWith(
                    color: colors.textTertiary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Store + Customer route
            Row(
              children: [
                // Route indicator dots
                Column(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: !isPickup
                            ? AppColors.success
                            : AppColors.warning,
                        border: Border.all(
                          color:
                              (!isPickup
                                      ? AppColors.success
                                      : AppColors.warning)
                                  .withAlpha(80),
                          width: 2,
                        ),
                      ),
                    ),
                    Container(
                      width: 1.5,
                      height: 22,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: colors.divider,
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: !isPickup
                            ? AppColors.primaryAccent
                            : colors.textTertiary.withAlpha(80),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.store_rounded,
                            size: 14,
                            color: isPickup
                                ? AppColors.warning
                                : AppColors.success,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              delivery.storeName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySm.copyWith(
                                color: isPickup
                                    ? colors.textPrimary
                                    : colors.textSecondary,
                                fontWeight: isPickup
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: !isPickup
                                ? AppColors.primaryAccent
                                : colors.textTertiary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              delivery.customerAddress.isNotEmpty
                                  ? delivery.customerAddress
                                  : delivery.customerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySm.copyWith(
                                color: !isPickup
                                    ? colors.textPrimary
                                    : colors.textTertiary,
                                fontWeight: !isPickup
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Earnings + tap arrow
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹${delivery.earnings.toStringAsFixed(0)}",
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs + 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(
                          colors.isDark ? 30 : 15,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Shown when there are no active deliveries
  Widget _buildEmptyCard(C colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl + 4,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: AppRadius.xlAll,
        border: Border.all(
          color: colors.blush.withAlpha(colors.isDark ? 50 : 100),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg + 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.warning.withAlpha(colors.isDark ? 50 : 30),
                    AppColors.warning.withAlpha(colors.isDark ? 25 : 10),
                  ],
                ),
              ),
              child: const Icon(
                Icons.delivery_dining_rounded,
                size: 38,
                color: AppColors.warning,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            "No Active Orders",
            style: AppTextStyles.headingSm.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              "You're all caught up! Stay online to receive new delivery requests.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySm.copyWith(
                color: colors.textTertiary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
