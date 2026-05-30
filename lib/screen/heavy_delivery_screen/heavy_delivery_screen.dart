import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bhukkdelivery/cards/heavy_delivery_screen/heavy_delivery_header_card.dart';
import 'package:bhukkdelivery/cards/heavy_delivery_screen/heavy_delivery_stats_card.dart';
import 'package:bhukkdelivery/cards/heavy_delivery_screen/heavy_delivery_earnings_card.dart';
import 'package:bhukkdelivery/cards/heavy_delivery_screen/heavy_delivery_actions_card.dart';
import 'package:bhukkdelivery/cards/home/promo_ads_card.dart';

class HeavyDeliveryScreen extends ConsumerStatefulWidget {
  const HeavyDeliveryScreen({super.key});

  @override
  ConsumerState<HeavyDeliveryScreen> createState() =>
      _HeavyDeliveryScreenState();
}

class _HeavyDeliveryScreenState extends ConsumerState<HeavyDeliveryScreen>
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

    final sections = <Widget>[
      const HeavyDeliveryHeaderCard(),
      const HeavyDeliveryStatsCard(),
      const HeavyDeliveryEarningsCard(),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Logistics Actions",
            style: AppTextStyles.headingSm.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const HeavyDeliveryActionsCard(),
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
