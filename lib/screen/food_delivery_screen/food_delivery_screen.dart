import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bhukkdelivery/cards/food_delivery_screen/food_delivery_header_card.dart';
import 'package:bhukkdelivery/cards/food_delivery_screen/food_delivery_stats_card.dart';
import 'package:bhukkdelivery/cards/food_delivery_screen/food_delivery_earnings_card.dart';
import 'package:bhukkdelivery/cards/food_delivery_screen/food_delivery_actions_card.dart';
import 'package:bhukkdelivery/cards/home/promo_ads_card.dart';
import 'package:bhukkdelivery/cards/home/service_status_card.dart';
import 'package:bhukkdelivery/providers/home/master_dashboard_provider.dart';
import 'package:bhukkdelivery/cards/home/new_order_popup_helper.dart';

class FoodDeliveryScreen extends ConsumerStatefulWidget {
  const FoodDeliveryScreen({super.key});

  @override
  ConsumerState<FoodDeliveryScreen> createState() => _FoodDeliveryScreenState();
}

class _FoodDeliveryScreenState extends ConsumerState<FoodDeliveryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Animation<double> _staggeredFade(int index) {
    final start = (index * 0.10).clamp(0.0, 0.7);
    final end = (start + 0.3).clamp(0.0, 1.0);
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  Animation<Offset> _staggeredSlide(int index) {
    final start = (index * 0.10).clamp(0.0, 0.7);
    final end = (start + 0.3).clamp(0.0, 1.0);
    return Tween<Offset>(
      begin: const Offset(0, 0.15),
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
    final dashboardState = ref.watch(masterDashboardProvider);
    final isOnline = dashboardState.services.firstWhere((s) => s.serviceId == 'food_delivery').isOnline;

    final sections = <Widget>[
      ServiceStatusCard(
        isOnline: isOnline,
        onToggle: () {
          final wasOffline = !isOnline;
          ref.read(masterDashboardProvider.notifier).toggleServiceById('food_delivery');
          if (wasOffline) {
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (!context.mounted) return;
              showNewOrderPopup(context, ref, 'food_delivery');
            });
          }
        },
      ),
      const FoodDeliveryHeaderCard(),
      const FoodDeliveryStatsCard(),
      const FoodDeliveryEarningsCard(),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Delivery Actions",
            style: AppTextStyles.headingSm.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          const FoodDeliveryActionsCard(),
        ],
      ),
      const PromoAdsCard(),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _staggerController,
          builder: (context, _) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < sections.length; i++) ...[
                    SlideTransition(
                      position: _staggeredSlide(i),
                      child: FadeTransition(
                        opacity: _staggeredFade(i),
                        child: sections[i],
                      ),
                    ),
                    if (i < sections.length - 1)
                      SizedBox(
                        height: i == 0 ? AppSpacing.xxl : AppSpacing.xl,
                      ),
                  ],
                  const SizedBox(height: 120),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
