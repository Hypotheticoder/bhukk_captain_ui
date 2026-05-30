import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LiveActivityCard extends ConsumerStatefulWidget {
  const LiveActivityCard({super.key});

  @override
  ConsumerState<LiveActivityCard> createState() => _LiveActivityCardState();
}

class _LiveActivityCardState extends ConsumerState<LiveActivityCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnim;
  late Animation<Offset> _bikeSlide;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _bikeSlide =
        Tween<Offset>(
          begin: const Offset(-0.1, 0),
          end: const Offset(1.1, 0),
        ).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final delivery = ref.watch(activeDeliveryProvider);

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, _) {
        // If there's an active delivery, show delivery-aware card
        if (delivery != null) {
          return _buildActiveDeliveryCard(context, delivery);
        }

        // Otherwise show the default idle live activity card
        return _buildIdleCard(context);
      },
    );
  }

  /// Active delivery card — shows current delivery progress
  Widget _buildActiveDeliveryCard(
    BuildContext context,
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
          borderRadius: AppRadius.xlAll,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isPickup
                ? [
                    const Color(0xFF7C3A0A),
                    AppColors.warning,
                    AppColors.starYellow.withAlpha(200),
                  ]
                : [
                    AppColors.darkCyan,
                    AppColors.primary,
                    AppColors.primaryAccent.withAlpha(200),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: (isPickup ? AppColors.warning : AppColors.primary)
                  .withAlpha((80 * _pulseAnim.value).toInt()),
              blurRadius: 25,
              offset: const Offset(0, 12),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: status + phase badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.online,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.online.withAlpha(
                              (150 * _pulseAnim.value).toInt(),
                            ),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      "ACTIVE DELIVERY",
                      style: AppTextStyles.overline.copyWith(
                        color: Colors.white70,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + 2,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: AppRadius.pillAll,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPickup
                            ? Icons.store_rounded
                            : Icons.person_pin_circle_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isPickup ? "Store Pickup" : "Delivering",
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Store / Customer info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm + 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: Icon(
                    isPickup ? Icons.store_rounded : Icons.location_on_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPickup ? delivery.storeName : delivery.customerName,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isPickup
                            ? (delivery.storeAddress.isNotEmpty
                                  ? delivery.storeAddress
                                  : "Heading to store")
                            : (delivery.customerAddress.isNotEmpty
                                  ? delivery.customerAddress
                                  : "Heading to customer"),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tap to open arrow
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLiveStat("Order", delivery.orderId),
                Container(
                  height: 30,
                  width: 1,
                  color: Colors.white.withAlpha(30),
                ),
                _buildLiveStat("Status", delivery.statusLabel),
                Container(
                  height: 30,
                  width: 1,
                  color: Colors.white.withAlpha(30),
                ),
                _buildLiveStat(
                  "Earnings",
                  "₹${delivery.earnings.toStringAsFixed(0)}",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Default idle card — no active delivery
  Widget _buildIdleCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: AppRadius.xlAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkCyan,
            AppColors.primary,
            AppColors.primaryAccent.withAlpha(200),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha((80 * _pulseAnim.value).toInt()),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.online,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.online.withAlpha(
                            (150 * _pulseAnim.value).toInt(),
                          ),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    "LIVE ACTIVITY",
                    style: AppTextStyles.overline.copyWith(
                      color: Colors.white70,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: AppRadius.pillAll,
                ),
                child: Text(
                  "Active Zone",
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          ClipRRect(
            borderRadius: AppRadius.mdAll,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                borderRadius: AppRadius.mdAll,
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 20,
                    right: 20,
                    top: 19,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: AppRadius.pillAll,
                      ),
                    ),
                  ),
                  ...List.generate(5, (i) {
                    return Positioned(
                      left:
                          20.0 +
                          i * ((MediaQuery.of(context).size.width - 120) / 4),
                      top: 16,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(60),
                        ),
                      ),
                    );
                  }),
                  SlideTransition(
                    position: _bikeSlide,
                    child: const Icon(
                      Icons.delivery_dining_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLiveStat("Distance", "24.5 km"),
              Container(
                height: 30,
                width: 1,
                color: Colors.white.withAlpha(30),
              ),
              _buildLiveStat("Active Time", "6.2 hrs"),
              Container(
                height: 30,
                width: 1,
                color: Colors.white.withAlpha(30),
              ),
              _buildLiveStat("Speed", "18 km/h"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.bodyMd.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
