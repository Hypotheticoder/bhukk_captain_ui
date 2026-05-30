import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bhukkdelivery/cards/home/header_card.dart';
import 'package:bhukkdelivery/cards/home/service_status_card.dart';
import 'package:bhukkdelivery/providers/home/master_dashboard_provider.dart';
import 'package:bhukkdelivery/cards/home/new_order_popup_helper.dart';
import 'package:bhukkdelivery/cards/home/earnings_card.dart';
import 'package:bhukkdelivery/cards/home/live_activity_card.dart';
import 'package:bhukkdelivery/cards/home/active_order_card.dart';
import 'package:bhukkdelivery/cards/beverages_screen/beverages_actions_card.dart';
import 'package:bhukkdelivery/cards/home/weekly_chart_card.dart';
import 'package:bhukkdelivery/cards/home/delivery_stats_card.dart';
import 'package:bhukkdelivery/cards/home/promo_ads_card.dart';

class BeveragesScreen extends ConsumerStatefulWidget {
  const BeveragesScreen({super.key});

  @override
  ConsumerState<BeveragesScreen> createState() => _BeveragesScreenState();
}

class _BeveragesScreenState extends ConsumerState<BeveragesScreen>
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
    final start = (index * 0.08).clamp(0.0, 0.7);
    final end = (start + 0.3).clamp(0.0, 1.0);
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  Animation<Offset> _staggeredSlide(int index) {
    final start = (index * 0.08).clamp(0.0, 0.7);
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
    final isOnline = dashboardState.services.firstWhere((s) => s.serviceId == 'beverages').isOnline;

    final sections = <Widget>[
      const HeaderCard(),
      ServiceStatusCard(
        isOnline: isOnline,
        onToggle: () {
          final wasOffline = !isOnline;
          ref.read(masterDashboardProvider.notifier).toggleServiceById('beverages');
          if (wasOffline) {
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (!context.mounted) return;
              showNewOrderPopup(context, ref, 'beverages');
            });
          }
        },
      ),
      const LiveActivityCard(),
      const EarningsCard(),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Quick Actions", colors),
          const SizedBox(height: AppSpacing.md),
          const BeveragesActionsCard(),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Analytics", colors),
          const SizedBox(height: AppSpacing.md),
          const WeeklyChartCard(),
        ],
      ),
      const DeliveryStatsCard(),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Active Deliveries", colors),
          const SizedBox(height: AppSpacing.md),
          const ActiveOrderCard(),
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

  Widget _buildSectionHeader(String title, C colors) {
    return Text(
      title,
      style: AppTextStyles.headingSm.copyWith(color: colors.textPrimary),
    );
  }
}
