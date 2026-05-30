import 'package:bhukkdelivery/cards/orders_screen/order_filter_chips.dart';
import 'package:bhukkdelivery/cards/orders_screen/order_item_card.dart';
import 'package:bhukkdelivery/cards/orders_screen/orders_header_card.dart';
import 'package:bhukkdelivery/cards/orders_screen/orders_stats_card.dart';
import 'package:bhukkdelivery/providers/orders/orders_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:bhukkdelivery/cards/home/promo_ads_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
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
      begin: const Offset(0, 0.1),
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
    final state = ref.watch(ordersProvider);
    final liveState = ref.watch(liveJobsProvider);

    // Merge live jobs into the orders notifier whenever they change.
    ref.listen(liveJobsProvider, (prev, next) {
      if (next.liveJobs.isNotEmpty) {
        Future.microtask(() {
          if (mounted) {
            ref.read(ordersProvider.notifier).addLiveJobs(next.liveJobs);
          }
        });
      }
    });

    final orders = state.filteredOrders;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _staggerController,
          builder: (context, _) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Fixed top section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SlideTransition(
                          position: _staggeredSlide(0),
                          child: FadeTransition(
                            opacity: _staggeredFade(0),
                            child: const OrdersHeaderCard(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        SlideTransition(
                          position: _staggeredSlide(1),
                          child: FadeTransition(
                            opacity: _staggeredFade(1),
                            child: const OrdersStatsCard(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        SlideTransition(
                          position: _staggeredSlide(2),
                          child: FadeTransition(
                            opacity: _staggeredFade(2),
                            child: const OrderFilterChips(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        // Section title with live indicator
                        SlideTransition(
                          position: _staggeredSlide(3),
                          child: FadeTransition(
                            opacity: _staggeredFade(3),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Recent Orders",
                                      style: AppTextStyles.bodyLg.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                    if (liveState.isConnected) ...[
                                      const SizedBox(width: AppSpacing.sm),
                                      _LiveIndicator(),
                                    ],
                                  ],
                                ),
                                Text(
                                  "${orders.length} orders",
                                  style: AppTextStyles.caption.copyWith(
                                    color: colors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                ),

                // Loading indicator for history or live jobs
                if (state.isLoading || liveState.isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  ),

                // Order list or empty state
                if (orders.isEmpty && !state.isLoading && !liveState.isLoading)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxxl),
                      child: Column(
                        children: [
                          const SizedBox(height: AppSpacing.huge),
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 56,
                            color: colors.textTertiary.withAlpha(100),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            liveState.isConnected
                                ? "Waiting for orders..."
                                : "No orders found",
                            style: AppTextStyles.bodyMd.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            liveState.isConnected
                                ? "New orders will appear here automatically"
                                : "Try a different search or filter",
                            style: AppTextStyles.caption.copyWith(
                              color: colors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return OrderItemCard(
                            order: orders[index],
                            animationIndex: index,
                          );
                        },
                        childCount: orders.length,
                      ),
                    ),
                  ),

                // Promo ads
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: const PromoAdsCard(),
                  ),
                ),

                // Bottom spacer
                const SliverToBoxAdapter(
                  child: SizedBox(height: 120),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// A small pulsing "● Live" indicator chip.
class _LiveIndicator extends StatefulWidget {
  @override
  State<_LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<_LiveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Opacity(
          opacity: 0.5 + (_pulseController.value * 0.5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.success.withAlpha(60),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'LIVE',
                  style: AppTextStyles.overline.copyWith(
                    fontSize: 8,
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
