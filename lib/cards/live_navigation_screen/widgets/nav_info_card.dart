import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:bhukkdelivery/services/map_service.dart';

class NavInfoCard extends StatelessWidget {
  final ActiveDelivery delivery;
  final AsyncValue<RouteResult> routeAsync;

  const NavInfoCard({
    super.key,
    required this.delivery,
    required this.routeAsync,
  });

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    String eta = delivery.isPickupPhase ? '8 min' : '12 min';
    String dist = '1.8 km';

    if (routeAsync.hasValue) {
      final result = routeAsync.value!;
      final durationMin = (result.totalDuration / 60).ceil();
      eta = '$durationMin min';
      if (result.totalDistance >= 1000) {
        dist = '${(result.totalDistance / 1000).toStringAsFixed(1)} km';
      } else {
        dist = '${result.totalDistance.toInt()} m';
      }
    }

    return ClipRRect(
      borderRadius: AppRadius.lgAll,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceElevated.withAlpha(colors.isDark ? 200 : 235),
            borderRadius: AppRadius.lgAll,
            border: Border.all(
              color: Colors.white.withAlpha(colors.isDark ? 20 : 100),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                eta,
                style: AppTextStyles.headingMd.copyWith(
                  color: AppColors.primary,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dist,
                style: AppTextStyles.caption.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
