import 'package:bhukkdelivery/models/order_request.dart';
import 'package:bhukkdelivery/notifiers/orders_screen/orders_notifier.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';

class NewOrderPopupCard extends StatefulWidget {
  final OrderRequest order;
  final int countdownSeconds;
  final int totalSeconds;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const NewOrderPopupCard({
    super.key,
    required this.order,
    required this.countdownSeconds,
    required this.totalSeconds,
    required this.onAccept,
    required this.onReject,
  });

  @override
  State<NewOrderPopupCard> createState() => _NewOrderPopupCardState();
}

class _NewOrderPopupCardState extends State<NewOrderPopupCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    // Slide up entrance
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 1.2), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Pulsing glow for earnings
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  bool get _isParcel =>
      widget.order.serviceType.toLowerCase().contains('parcel');

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    final order = widget.order;
    String svcKey = 'parcel';
    final type = order.serviceType.toLowerCase();
    
    if (type.contains('ride') || type == 'car' || type == 'car_booking') {
      svcKey = 'ride';
    } else if (type.contains('medicine') || type.contains('pharmacy')) {
      svcKey = 'medicine';
    }

    final serviceMeta = serviceMetaMap[svcKey] ?? serviceMetaMap['parcel']!;

    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: AppRadius.xlAll,
            border: Border.all(
              color: AppColors.primaryAccent.withAlpha(colors.isDark ? 40 : 60),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(colors.isDark ? 40 : 50),
                blurRadius: 35,
                offset: const Offset(0, 15),
                spreadRadius: 3,
              ),
              BoxShadow(
                color: colors.cardShadow(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Top accent strip ──
              Container(
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 60),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryAccent],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(3),
                    bottomRight: Radius.circular(3),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Header row: Service label + countdown ──
                    Row(
                      children: [
                        // Service icon
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                serviceMeta.color.withAlpha(
                                  colors.isDark ? 50 : 30,
                                ),
                                serviceMeta.color.withAlpha(
                                  colors.isDark ? 20 : 10,
                                ),
                              ],
                            ),
                            borderRadius: AppRadius.smAll,
                          ),
                          child: Icon(
                            serviceMeta.icon,
                            color: serviceMeta.color,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "New ${serviceMeta.label} Order!",
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                "Respond before time runs out",
                                style: AppTextStyles.caption.copyWith(
                                  color: colors.textTertiary,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Circular countdown
                        _CountdownRing(
                          seconds: widget.countdownSeconds,
                          total: widget.totalSeconds,
                          colors: colors,
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // ── Store info + Earnings ──
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm + 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.blush.withAlpha(colors.isDark ? 18 : 45),
                        borderRadius: AppRadius.mdAll,
                      ),
                      child: Row(
                        children: [
                          // Store icon
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
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
                              svcKey == 'medicine' 
                                  ? Icons.local_pharmacy_rounded 
                                  : (_isParcel ? Icons.inventory_2_rounded : Icons.store_rounded),
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          // Store name + cuisine
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
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        order.cuisineType,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.caption.copyWith(
                                          color: colors.textTertiary,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
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
                          // Earnings with pulse
                          AnimatedBuilder(
                            animation: _pulseAnim,
                            builder: (context, child) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm + 2,
                                  vertical: AppSpacing.xs + 2,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.success.withAlpha(
                                        (colors.isDark ? 30 : 18) +
                                            (10 * _pulseAnim.value).toInt(),
                                      ),
                                      AppColors.success.withAlpha(
                                        (colors.isDark ? 15 : 8) +
                                            (8 * _pulseAnim.value).toInt(),
                                      ),
                                    ],
                                  ),
                                  borderRadius: AppRadius.smAll,
                                  border: Border.all(
                                    color: AppColors.success.withAlpha(
                                      35 + (20 * _pulseAnim.value).toInt(),
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "₹${order.earnings.toStringAsFixed(0)}",
                                      style: AppTextStyles.bodyMd.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.success,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "EARN",
                                      style: AppTextStyles.overline.copyWith(
                                        color: AppColors.success,
                                        fontSize: 7,
                                        letterSpacing: 1.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // ── Route visualization: pickup → drop (compact) ──
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm + 2,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: colors.blush.withAlpha(colors.isDark ? 12 : 30),
                        borderRadius: AppRadius.smAll,
                      ),
                      child: Row(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.success,
                                  border: Border.all(
                                    color: AppColors.success.withAlpha(60),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 14,
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.success,
                                      AppColors.error,
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.error,
                                  border: Border.all(
                                    color: AppColors.error.withAlpha(60),
                                    width: 1.5,
                                  ),
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

                    // ── Stats row: distance · time · items (parcel only) · payment ──
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                        horizontal: AppSpacing.sm,
                      ),
                      decoration: colors.infoRow,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStat(
                            Icons.straighten_rounded,
                            order.distance,
                            "Distance",
                            AppColors.primary,
                            colors,
                          ),
                          _statDivider(colors),
                          _buildStat(
                            Icons.timer_outlined,
                            "${order.estimatedTime} min",
                            "Est. Time",
                            AppColors.warning,
                            colors,
                          ),
                          if (_isParcel) ...[
                            _statDivider(colors),
                            _buildStat(
                              Icons.shopping_bag_outlined,
                              "${order.itemCount}",
                              "Items",
                              AppColors.info,
                              colors,
                            ),
                          ],
                          _statDivider(colors),
                          _buildStat(
                            Icons.payment_rounded,
                            order.paymentMethod,
                            "Pay",
                            AppColors.purple,
                            colors,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // ── Descriptive Payout Breakdown ──
                    Builder(
                      builder: (context) {
                        final distanceKm = _parseDistanceKm(order.distance);
                        final perKmRate = distanceKm > 0
                            ? (order.distanceFare / distanceKm)
                            : 0.0;

                        return Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: colors.surfaceElevated.withAlpha(
                              colors.isDark ? 60 : 120,
                            ),
                            borderRadius: AppRadius.mdAll,
                            border: Border.all(
                              color: AppColors.primary.withAlpha(20),
                              width: 0.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colors.cardShadow(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withAlpha(18),
                                      borderRadius: AppRadius.smAll,
                                    ),
                                    child: const Icon(
                                      Icons.receipt_long_rounded,
                                      color: AppColors.primary,
                                      size: 13,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    "Payment Details",
                                    style: AppTextStyles.label.copyWith(
                                      color: colors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.purple.withAlpha(18),
                                      borderRadius: AppRadius.smAll,
                                      border: Border.all(
                                        color: AppColors.purple.withAlpha(35),
                                      ),
                                    ),
                                    child: Text(
                                      order.paymentMethod.toUpperCase(),
                                      style: AppTextStyles.overline.copyWith(
                                        color: AppColors.purple,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 8,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.xs + 1,
                                ),
                                child: Divider(
                                  color: colors.divider.withAlpha(40),
                                  height: 1,
                                ),
                              ),

                              // Customer Total Bill
                              if (order.customerOrderAmount > 0) ...[
                                _buildPayoutRow(
                                  'Customer Total Bill',
                                  '₹${order.customerOrderAmount.toStringAsFixed(0)}',
                                  colors.textSecondary,
                                  colors.textPrimary,
                                  colors,
                                  isBold: true,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                              ],

                              // Incentive (base fare)
                              _buildPayoutRow(
                                'Incentive',
                                '₹${order.baseFare.toStringAsFixed(0)}',
                                colors.textSecondary,
                                colors.textSecondary,
                                colors,
                              ),
                              const SizedBox(height: 3),

                              // Per km charge
                              _buildPayoutRow(
                                'Per km charge',
                                '₹${perKmRate.toStringAsFixed(0)} × ${distanceKm.toStringAsFixed(2)} km',
                                colors.textTertiary,
                                colors.textSecondary,
                                colors,
                              ),
                              const SizedBox(height: 3),

                              // Total (roundup) distance fare
                              _buildPayoutRow(
                                'Total(roundup)',
                                '₹${order.distanceFare.toStringAsFixed(2)} (₹${order.distanceFare.toStringAsFixed(0)})',
                                colors.textSecondary,
                                colors.textSecondary,
                                colors,
                              ),

                              // Platform Fee
                              const SizedBox(height: 3),
                              _buildPayoutRow(
                                'Platform Fee (taken)',
                                '- ₹${order.platformFee.toStringAsFixed(2)}',
                                colors.textSecondary,
                                AppColors.error,
                                colors,
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.xs + 1,
                                ),
                                child: Divider(
                                  color: colors.divider.withAlpha(50),
                                  height: 1,
                                ),
                              ),

                              // YOUR EARNINGS
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'YOUR EARNINGS',
                                    style: AppTextStyles.overline.copyWith(
                                      letterSpacing: 1.0,
                                      color: AppColors.primaryAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9,
                                    ),
                                  ),
                                  Text(
                                    '₹${order.earnings.toStringAsFixed(0)}',
                                    style: AppTextStyles.headingSm.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.success,
                                      fontSize: 18,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // ── Action buttons: Reject / Accept ──
                    Row(
                      children: [
                        // Reject
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: widget.onReject,
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: AppRadius.pillAll,
                                border: Border.all(
                                  color: colors.blush.withAlpha(
                                    colors.isDark ? 80 : 160,
                                  ),
                                  width: 1.5,
                                ),
                                color: colors.isDark
                                    ? colors.surfaceElevated
                                    : null,
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                      color: colors.textSecondary,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      "Reject",
                                      style: AppTextStyles.label.copyWith(
                                        color: colors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        // Accept
                        Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTap: widget.onAccept,
                            child: Container(
                              height: 44,
                              decoration: AppButtonStyles.primaryButton,
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline_rounded,
                                      size: 18,
                                      color: AppColors.textOnPrimary,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      "Accept Order",
                                      style: AppTextStyles.label.copyWith(
                                        color: AppColors.textOnPrimary,
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

  Widget _buildStat(
    IconData icon,
    String value,
    String label,
    Color color,
    C colors,
  ) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              fontSize: 11,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.overline.copyWith(
              color: colors.textTertiary,
              fontSize: 8,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider(C colors) {
    return Container(
      height: 22,
      width: 0.5,
      color: colors.textTertiary.withAlpha(40),
    );
  }

  Widget _buildPayoutRow(
    String label,
    String value,
    Color labelColor,
    Color valueColor,
    C colors, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: labelColor,
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            color: valueColor,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  double _parseDistanceKm(String distanceText) {
    final text = distanceText.toLowerCase().replaceAll('km', '').trim();
    return double.tryParse(text) ?? 0.0;
  }
}

// ── Countdown Ring Widget ──────────────────────────
class _CountdownRing extends StatelessWidget {
  final int seconds;
  final int total;
  final C colors;

  const _CountdownRing({
    required this.seconds,
    required this.total,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? seconds / total : 0.0;
    final isUrgent = seconds <= 10;

    final ringColor = isUrgent ? AppColors.error : AppColors.primary;

    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 3,
              color: colors.blush.withAlpha(colors.isDark ? 40 : 80),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Progress ring
          SizedBox(
            width: 44,
            height: 44,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: progress, end: progress),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              builder: (context, value, _) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 3,
                  color: ringColor,
                  strokeCap: StrokeCap.round,
                );
              },
            ),
          ),
          // Seconds text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$seconds",
                style: AppTextStyles.headingSm.copyWith(
                  color: isUrgent ? AppColors.error : colors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  height: 1,
                ),
              ),
              Text(
                "sec",
                style: AppTextStyles.overline.copyWith(
                  color: colors.textTertiary,
                  fontSize: 7,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
