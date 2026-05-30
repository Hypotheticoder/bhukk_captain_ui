import 'package:bhukkdelivery/notifiers/orders_screen/orders_notifier.dart';
import 'package:bhukkdelivery/providers/orders/orders_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';

class OrderItemCard extends StatefulWidget {
  final OrderItem order;
  final int animationIndex;

  const OrderItemCard({
    super.key,
    required this.order,
    this.animationIndex = 0,
  });

  @override
  State<OrderItemCard> createState() => _OrderItemCardState();
}

class _OrderItemCardState extends State<OrderItemCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    final order = widget.order;

    final statusColor = _statusColor(order.status);
    final statusLabel = _statusLabel(order.status);
    final serviceMeta =
        serviceMetaMap[order.serviceType] ?? serviceMetaMap['parcel']!;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 450 + widget.animationIndex * 80),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: AppRadius.xlAll,
            border: Border.all(
              color: colors.blush.withAlpha(colors.isDark ? 25 : 60),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.cardShadow(0.05),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Service accent bar ──
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      serviceMeta.color,
                      serviceMeta.color.withAlpha(120),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    // ── Top row: store + status + service badge ──
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm + 2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                serviceMeta.color
                                    .withAlpha(colors.isDark ? 45 : 25),
                                serviceMeta.color
                                    .withAlpha(colors.isDark ? 20 : 10),
                              ],
                            ),
                            borderRadius: AppRadius.mdAll,
                          ),
                          child: Icon(serviceMeta.icon,
                              color: serviceMeta.color, size: 20),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.storeName,
                                style: AppTextStyles.bodyMd.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      "${_shortId(order.id)} • ${_timeAgo(order.dateTime)}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.caption.copyWith(
                                        color: colors.textTertiary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: serviceMeta.color
                                          .withAlpha(colors.isDark ? 30 : 15),
                                      borderRadius: AppRadius.pillAll,
                                    ),
                                    child: Text(
                                      serviceMeta.label,
                                      style: AppTextStyles.overline.copyWith(
                                        fontSize: 8,
                                        color: serviceMeta.color,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "₹${order.amount.toStringAsFixed(0)}",
                              style: AppTextStyles.bodyMd.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor
                                    .withAlpha(colors.isDark ? 30 : 15),
                                borderRadius: AppRadius.pillAll,
                              ),
                              child: Text(
                                statusLabel,
                                style: AppTextStyles.overline.copyWith(
                                  fontSize: 9,
                                  color: statusColor,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // ── Route visualization ──
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.md),
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
                                height: 28,
                                margin: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.xs),
                                decoration: BoxDecoration(
                                  color: colors.divider,
                                  borderRadius: BorderRadius.circular(1),
                                ),
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
                                const SizedBox(height: AppSpacing.lg + 6),
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

                    // ── Price Breakdown (Expandable) ──
                    if (_isExpanded) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: colors.blush.withAlpha(colors.isDark ? 15 : 40),
                          borderRadius: AppRadius.lgAll,
                          border: Border.all(
                            color: colors.divider.withAlpha(50),
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            if (order.customerOrderAmount > 0) ...[
                              _buildBreakdownRow(
                                "Customer Bill",
                                "₹${order.customerOrderAmount.toStringAsFixed(0)}",
                                colors.textPrimary,
                                colors,
                                isBold: true,
                              ),
                              if (order.platformFee > 0) ...[
                                const SizedBox(height: AppSpacing.xs),
                                _buildBreakdownRow(
                                  "Platform Fee",
                                  "- ₹${order.platformFee.toStringAsFixed(0)}",
                                  AppColors.error,
                                  colors,
                                ),
                              ],
                              const SizedBox(height: AppSpacing.sm),
                              Divider(color: colors.divider.withAlpha(40), height: 1),
                              const SizedBox(height: AppSpacing.sm),
                            ],
                            
                            // Earnings components
                            _buildBreakdownRow(
                              "Base Fare (Incentive)",
                              "₹${order.baseFare.toStringAsFixed(0)}",
                              colors.textSecondary,
                              colors,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            _buildBreakdownRow(
                              "Distance Fare (${order.distanceKm.toStringAsFixed(1)} km)",
                              "₹${order.distanceFare.toStringAsFixed(0)}",
                              colors.textSecondary,
                              colors,
                            ),
                            
                            const SizedBox(height: AppSpacing.md),
                            Divider(color: colors.divider.withAlpha(40), height: 1),
                            const SizedBox(height: AppSpacing.md),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "YOUR EARNINGS",
                                  style: AppTextStyles.overline.copyWith(
                                    letterSpacing: 1.2,
                                    color: AppColors.primaryAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  "₹${order.amount.toStringAsFixed(0)}",
                                  style: AppTextStyles.headingSm.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.success,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // ── Divider ──
                    Container(height: 0.5, color: colors.divider),

                    // ── Bottom stats row ──
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Wrap(
                            spacing: AppSpacing.md,
                            runSpacing: AppSpacing.sm,
                            children: [
                              _buildBottomStat(
                                Icons.straighten_rounded,
                                "${order.distanceKm.toStringAsFixed(1)} km",
                                colors,
                              ),
                              if (order.durationMin > 0)
                                _buildBottomStat(
                                  Icons.timer_outlined,
                                  order.status == OrderStatus.cancelled
                                      ? "--"
                                      : "${order.durationMin} min",
                                  colors,
                                ),
                              _buildBottomStat(
                                order.paymentMethod.toUpperCase() == 'COD'
                                    ? Icons.payments_rounded
                                    : Icons.credit_card_rounded,
                                order.paymentMethod,
                                colors,
                              ),
                            ],
                          ),
                          Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: colors.textTertiary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value, Color valueColor, C colors,
      {bool isBold = false, bool large = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isBold ? colors.textPrimary : colors.textSecondary,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            fontSize: large ? 13 : 12,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodySm.copyWith(
            color: valueColor,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            fontSize: large ? 14 : 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomStat(IconData icon, String label, C colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: colors.textTertiary),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: colors.textTertiary,
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.completed:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
      case OrderStatus.inProgress:
        return AppColors.warning;
    }
  }

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.completed:
        return 'COMPLETED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
      case OrderStatus.inProgress:
        return 'IN PROGRESS';
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  String _shortId(String id) {
    if (id.length > 8) return "#${id.substring(0, 8).toUpperCase()}";
    return "#$id";
  }
}
