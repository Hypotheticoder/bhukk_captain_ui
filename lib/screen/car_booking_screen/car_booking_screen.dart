import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bhukkdelivery/cards/car_booking_screen/car_booking_header_card.dart';
import 'package:bhukkdelivery/cards/car_booking_screen/car_booking_stats_card.dart';
import 'package:bhukkdelivery/cards/car_booking_screen/car_booking_earnings_card.dart';
import 'package:bhukkdelivery/cards/car_booking_screen/car_booking_actions_card.dart';
import 'package:bhukkdelivery/cards/home/promo_ads_card.dart';
import 'package:bhukkdelivery/cards/home/service_status_card.dart';
import 'package:bhukkdelivery/providers/home/master_dashboard_provider.dart';
import 'package:bhukkdelivery/cards/home/new_order_popup_helper.dart';

class CarBookingScreen extends ConsumerStatefulWidget {
  const CarBookingScreen({super.key});

  @override
  ConsumerState<CarBookingScreen> createState() => _CarBookingScreenState();
}

class _CarBookingScreenState extends ConsumerState<CarBookingScreen>
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
    final service = dashboardState.services.where((s) => s.serviceId == 'car_booking').firstOrNull;
    final isOnline = service?.isOnline ?? false;

    final sections = <Widget>[
      ServiceStatusCard(
        isOnline: isOnline,
        onToggle: () {
          final wasOffline = !isOnline;
          ref.read(masterDashboardProvider.notifier).toggleServiceById('car_booking');
          if (wasOffline) {
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (!context.mounted) return;
              showNewOrderPopup(context, ref, 'car_booking');
            });
          }
        },
      ),
      const CarBookingHeaderCard(),
      const CarBookingStatsCard(),
      const CarBookingEarningsCard(),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Booking Actions",
            style: AppTextStyles.headingSm.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          const CarBookingActionsCard(),
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
