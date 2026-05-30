import 'package:flutter/material.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';

class PhaseBadge extends StatelessWidget {
  final ActiveDelivery delivery;

  const PhaseBadge({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    final isPickup = delivery.isPickupPhase;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: (isPickup ? AppColors.warning : AppColors.success).withAlpha(
          colors.isDark ? 200 : 230,
        ),
        borderRadius: AppRadius.pillAll,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPickup ? Icons.store_rounded : Icons.person_pin_circle_rounded,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            isPickup ? "TO STORE" : "TO CUSTOMER",
            style: AppTextStyles.label.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
