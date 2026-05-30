import 'package:bhukkdelivery/cards/new_order_request_screen/order_request_header_card.dart';
import 'package:bhukkdelivery/providers/new_order/new_order_provider.dart';
import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NewOrderRequestScreen extends ConsumerStatefulWidget {
  const NewOrderRequestScreen({super.key});

  @override
  ConsumerState<NewOrderRequestScreen> createState() =>
      _NewOrderRequestScreenState();
}

class _NewOrderRequestScreenState extends ConsumerState<NewOrderRequestScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;

  bool _parcelEnabled = true;
  bool _rideEnabled = true;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    // Initial fetch: show both Parcel + Ride by default.
    Future.microtask(() {
      ref.read(newOrderProvider.notifier).fetchOrdersForServices(const [
        'parcel',
        'car_booking',
      ]);
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Animation<double> _staggeredFade(int index) {
    final start = (index * 0.12).clamp(0.0, 0.7);
    final end = (start + 0.3).clamp(0.0, 1.0);
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  Animation<Offset> _staggeredSlide(int index) {
    final start = (index * 0.12).clamp(0.0, 0.7);
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
    final state = ref.watch(newOrderProvider);
    final orders = state.orders;
    final currentOrder = state.selectedOrder;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: AppRadius.mdAll,
              boxShadow: [
                BoxShadow(
                  color: colors.cardShadow(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: colors.textPrimary,
              size: 22,
            ),
          ),
        ),
      ),
      body: !state.hasOrders
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 56,
                    color: colors.textTertiary.withAlpha(100),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    "No orders available",
                    style: AppTextStyles.bodyMd.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    "Check back later for new orders",
                    style: AppTextStyles.caption.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            )
          : AnimatedBuilder(
              animation: _staggerController,
              builder: (context, _) {
                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: SlideTransition(
                          position: _staggeredSlide(0),
                          child: FadeTransition(
                            opacity: _staggeredFade(0),
                            child: OrderRequestHeaderCard(
                              orderCount: orders.length,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.lg),
                    ),

                    // Parcel / Ride toggle buttons
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: SlideTransition(
                          position: _staggeredSlide(1),
                          child: FadeTransition(
                            opacity: _staggeredFade(1),
                            child: _ServiceToggleRow(
                              colors: colors,
                              parcelEnabled: _parcelEnabled,
                              rideEnabled: _rideEnabled,
                              onParcelToggle: () {
                                setState(() {
                                  _parcelEnabled = !_parcelEnabled;
                                });
                                _refetchForToggles();
                              },
                              onRideToggle: () {
                                setState(() {
                                  _rideEnabled = !_rideEnabled;
                                });
                                _refetchForToggles();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.xxl),
                    ),

                    // One-by-one order card
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: currentOrder == null
                            ? const SizedBox.shrink()
                            : TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 500),
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
                                child: _OrderListItem(
                                  order: currentOrder,
                                  colors: colors,
                                  onAccept: () async {
                                    await ref
                                        .read(newOrderProvider.notifier)
                                        .acceptOrder();

                                    if (!context.mounted) return;

                                    // Only navigate if a delivery was started
                                    final hasDelivery =
                                        ref.read(activeDeliveryProvider) !=
                                            null;
                                    if (!hasDelivery) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Order from ${currentOrder.storeName} accepted!",
                                        ),
                                      ),
                                    );
                                    context.push('/home/live_navigation');
                                  },
                                  onReject: () {
                                    ref
                                        .read(newOrderProvider.notifier)
                                        .rejectOrder();
                                  },
                                ),
                              ),
                      ),
                    ),

                    // Add extra bottom spacing so content doesn't get
                    // obscured by the floating bottom navigation bar.
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height:
                            AppSpacing.huge +
                            // Floating nav height (68) + its bottom margin (AppSpacing.xxl)
                            (68 + AppSpacing.xxl) +
                            MediaQuery.of(context).padding.bottom,
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  void _refetchForToggles() {
    final serviceTypes = <String>[];
    if (_parcelEnabled) serviceTypes.add('parcel');
    if (_rideEnabled) serviceTypes.add('car_booking');
    ref.read(newOrderProvider.notifier).fetchOrdersForServices(serviceTypes);
  }
}

class _ServiceToggleRow extends StatelessWidget {
  final C colors;
  final bool parcelEnabled;
  final bool rideEnabled;
  final VoidCallback onParcelToggle;
  final VoidCallback onRideToggle;

  const _ServiceToggleRow({
    required this.colors,
    required this.parcelEnabled,
    required this.rideEnabled,
    required this.onParcelToggle,
    required this.onRideToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TogglePill(
            label: 'Parcel',
            icon: Icons.inventory_2_rounded,
            activeColor: AppColors.parcel,
            isActive: parcelEnabled,
            colors: colors,
            onTap: onParcelToggle,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _TogglePill(
            label: 'Ride',
            icon: Icons.directions_car_rounded,
            activeColor: AppColors.carBooking,
            isActive: rideEnabled,
            colors: colors,
            onTap: onRideToggle,
          ),
        ),
      ],
    );
  }
}

class _TogglePill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color activeColor;
  final bool isActive;
  final C colors;
  final VoidCallback onTap;

  const _TogglePill({
    required this.label,
    required this.icon,
    required this.activeColor,
    required this.isActive,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isActive
        ? activeColor.withAlpha(colors.isDark ? 35 : 18)
        : colors.surfaceElevated;
    final border = isActive
        ? activeColor.withAlpha(colors.isDark ? 80 : 70)
        : colors.divider;
    final fg = isActive ? activeColor : colors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.pillAll,
          border: Border.all(color: border, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Individual Order List Item with inline Accept/Reject ──
class _OrderListItem extends StatelessWidget {
  final OrderRequest order;
  final C colors;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _OrderListItem({
    required this.order,
    required this.colors,
    required this.onAccept,
    required this.onReject,
  });

  bool get _isParcel =>
      order.serviceType.toLowerCase().contains('parcel');

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: AppRadius.xlAll,
        border: Border.all(
          color: colors.blush.withAlpha(colors.isDark ? 25 : 60),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header: Icon + Name + Payment badge ──
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withAlpha(
                              colors.isDark ? 40 : 22,
                            ),
                            AppColors.primary.withAlpha(
                              colors.isDark ? 18 : 8,
                            ),
                          ],
                        ),
                        borderRadius: AppRadius.smAll,
                      ),
                      child: Icon(
                        _isParcel
                            ? Icons.inventory_2_rounded
                            : Icons.directions_car_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.storeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.label.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Row(
                            children: [
                              Text(
                                order.cuisineType,
                                style: AppTextStyles.caption.copyWith(
                                  color: colors.textTertiary,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                ' • ',
                                style: AppTextStyles.caption.copyWith(
                                  color: colors.textTertiary,
                                  fontSize: 10,
                                ),
                              ),
                              const Icon(
                                Icons.star_rounded,
                                size: 10,
                                color: AppColors.starYellow,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                order.restaurantRating.toStringAsFixed(1),
                                style: AppTextStyles.caption.copyWith(
                                  color: colors.textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.info.withAlpha(
                          colors.isDark ? 28 : 14,
                        ),
                        borderRadius: AppRadius.pillAll,
                      ),
                      child: Text(
                        order.paymentMethod,
                        style: AppTextStyles.overline.copyWith(
                          fontSize: 8,
                          color: AppColors.info,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // ── Route (pickup → drop) ──
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + 2,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: colors.blush.withAlpha(colors.isDark ? 12 : 35),
                    borderRadius: AppRadius.smAll,
                  ),
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.success,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 14,
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            color: colors.divider,
                          ),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: AppSpacing.sm),
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
                                fontSize: 10.5,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm + 4),
                            Text(
                              order.dropAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(
                                color: colors.textSecondary,
                                fontWeight: FontWeight.w500,
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // ── Stats row (conditionally show items for parcel only) ──
                Row(
                  children: [
                    _buildMiniStat(
                      Icons.straighten_rounded,
                      order.distance,
                      colors,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _buildMiniStat(
                      Icons.timer_outlined,
                      "${order.estimatedTime} min",
                      colors,
                    ),
                    if (_isParcel) ...[
                      const SizedBox(width: AppSpacing.md),
                      _buildMiniStat(
                        Icons.shopping_bag_outlined,
                        "${order.itemCount} items",
                        colors,
                      ),
                    ],
                    const Spacer(),
                    // Earnings badge — prominent
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm + 2,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(
                          colors.isDark ? 25 : 15,
                        ),
                        borderRadius: AppRadius.pillAll,
                        border: Border.all(
                          color: AppColors.success.withAlpha(
                            colors.isDark ? 50 : 40,
                          ),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        '₹${order.earnings.toStringAsFixed(0)}',
                        style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // ── Compact Payout Breakdown ──
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + 2,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated.withAlpha(
                      colors.isDark ? 50 : 100,
                    ),
                    borderRadius: AppRadius.smAll,
                    border: Border.all(
                      color: AppColors.primary.withAlpha(15),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Fare rows in a single tight block
                      Row(
                        children: [
                          Expanded(
                            child: _buildPayoutChip(
                              'Base',
                              '₹${order.baseFare.toStringAsFixed(0)}',
                              colors.textSecondary,
                              colors.textPrimary,
                            ),
                          ),
                          Container(
                            width: 0.5,
                            height: 20,
                            color: colors.divider.withAlpha(60),
                          ),
                          Expanded(
                            child: _buildPayoutChip(
                              'Distance',
                              '₹${order.distanceFare.toStringAsFixed(0)}',
                              colors.textSecondary,
                              colors.textPrimary,
                            ),
                          ),
                          if (order.platformFee > 0) ...[
                            Container(
                              width: 0.5,
                              height: 20,
                              color: colors.divider.withAlpha(60),
                            ),
                            Expanded(
                              child: _buildPayoutChip(
                                'Platform',
                                '-₹${order.platformFee.toStringAsFixed(0)}',
                                colors.textSecondary,
                                AppColors.error,
                              ),
                            ),
                          ],
                          if (order.customerOrderAmount > 0) ...[
                            Container(
                              width: 0.5,
                              height: 20,
                              color: colors.divider.withAlpha(60),
                            ),
                            Expanded(
                              child: _buildPayoutChip(
                                'Bill',
                                '₹${order.customerOrderAmount.toStringAsFixed(0)}',
                                colors.textSecondary,
                                colors.textPrimary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ──
          Container(height: 0.5, color: colors.divider.withAlpha(80)),

          // ── Action buttons row ──
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onReject,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: colors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Skip",
                            style: AppTextStyles.caption.copyWith(
                              color: colors.textTertiary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 20,
                  width: 0.5,
                  color: colors.divider.withAlpha(80),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: onAccept,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 14,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Accept",
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String label, C colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: colors.textTertiary),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: colors.textTertiary,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPayoutChip(
    String label,
    String value,
    Color labelColor,
    Color valueColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: labelColor,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
