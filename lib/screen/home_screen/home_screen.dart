import 'package:bhukkdelivery/providers/ads/ads_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bhukkdelivery/cards/home/header_card.dart';
import 'package:bhukkdelivery/cards/home/service_grid_card.dart';
import 'package:bhukkdelivery/cards/home/aggregated_stats_card.dart';
import 'package:bhukkdelivery/cards/home/promo_ads_card.dart';
import 'package:bhukkdelivery/cards/home/earnings_card.dart';
import 'package:bhukkdelivery/cards/home/weekly_chart_card.dart';
import 'package:bhukkdelivery/cards/home/delivery_stats_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Animation<double> _staggeredFade(int index) {
    final start = (index * 0.07).clamp(0.0, 0.7);
    final end = (start + 0.3).clamp(0.0, 1.0);
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  Animation<Offset> _staggeredSlide(int index) {
    final start = (index * 0.07).clamp(0.0, 0.7);
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

  Future<void> _handleRefresh() async {
    // Invalidate providers to force a refetch
    ref.invalidate(adsCarouselProvider);
    // Add a tiny delay to ensure the UI shows the refresh indicator briefly
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    final sections = <Widget>[
      // ── 0. Header (logo, greeting, notifications, profile) ──
      const HeaderCard(),

      // ── 1. Service grid (2×3 animated tiles) ──
      const ServiceGridCard(),

      // ── 2. Promotions & Ads carousel ──
      const PromoAdsCard(),

      // ── 3. Aggregated stats (totals across all services) ──
      const AggregatedStatsCard(),

      // ── 3. Earnings overview ──
      const EarningsCard(),

      // ── 4. Weekly analytics chart ──
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Analytics", colors),
          const SizedBox(height: AppSpacing.md),
          const WeeklyChartCard(),
        ],
      ),

      // ── 6. Delivery stats ──
      const DeliveryStatsCard(),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: colors.surface,
          onRefresh: _handleRefresh,
          child: AnimatedBuilder(
            animation: _staggerController,
            builder: (context, _) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
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
                          height: i <= 1 ? AppSpacing.xxl : AppSpacing.xl,
                        ),
                    ],
                    const SizedBox(height: 120),
                  ],
                ),
              );
            },
          ),
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
