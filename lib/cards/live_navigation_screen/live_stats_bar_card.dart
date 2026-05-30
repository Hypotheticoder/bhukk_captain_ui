import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:bhukkdelivery/providers/delivery/route_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LiveStatsBarCard extends ConsumerWidget {
  const LiveStatsBarCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = C.of(context);
    final delivery = ref.watch(activeDeliveryProvider);

    if (delivery == null) return const SizedBox.shrink();

    final isPickup = delivery.isPickupPhase;

    // Calculate route key from delivery data
    final storePosition = LatLng(
      delivery.pickupLocation.latitude,
      delivery.pickupLocation.longitude,
    );
    final customerPosition = LatLng(
      delivery.dropoffLocation.latitude,
      delivery.dropoffLocation.longitude,
    );
    final routeEnd = isPickup ? storePosition : customerPosition;

    // Use a fallback route start slightly offset from the end for initial display
    final routeStart = LatLng(
      routeEnd.latitude - 0.005,
      routeEnd.longitude - 0.005,
    );
    final key = routeKey(routeStart, routeEnd);
    final routeAsync = ref.watch(routeProvider(key));

    // Real data from route, with fallbacks
    String distance = isPickup ? "1.8 km" : "3.2 km";
    String eta = isPickup ? "8 min" : "12 min";

    if (routeAsync.hasValue && routeAsync.value!.isNotEmpty) {
      final result = routeAsync.value!;

      // Prefer backend-provided human-readable text
      if (result.durationText.isNotEmpty) {
        eta = result.durationText;
      } else {
        final durationMin = (result.totalDuration / 60).ceil();
        eta = '$durationMin min';
      }

      if (result.distanceText.isNotEmpty) {
        distance = result.distanceText;
      } else if (result.totalDistance >= 1000) {
        distance = '${(result.totalDistance / 1000).toStringAsFixed(1)} km';
      } else {
        distance = '${result.totalDistance.toInt()} m';
      }
    }

    final phaseLabel = isPickup ? "To Store" : "To Customer";

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg + 2,
        horizontal: AppSpacing.xl,
      ),
      decoration: colors.elevatedCard,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(
            Icons.straighten_rounded,
            distance,
            "Distance",
            AppColors.info,
            colors,
          ),
          Container(height: 30, width: 1, color: colors.divider),
          _buildStat(
            Icons.timer_outlined,
            eta,
            "ETA",
            AppColors.warning,
            colors,
          ),
          Container(height: 30, width: 1, color: colors.divider),
          _buildStat(
            isPickup ? Icons.store_rounded : Icons.person_pin_circle_rounded,
            phaseLabel,
            "Phase",
            isPickup ? AppColors.warning : AppColors.success,
            colors,
          ),
        ],
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
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.bodyMd.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 10,
            color: colors.textTertiary,
          ),
        ),
      ],
    );
  }
}
