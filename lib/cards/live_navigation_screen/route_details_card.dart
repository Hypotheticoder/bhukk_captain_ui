import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RouteDetailsCard extends ConsumerWidget {
  const RouteDetailsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = C.of(context);
    final delivery = ref.watch(activeDeliveryProvider);

    if (delivery == null) return const SizedBox.shrink();

    final isPickupPhase = delivery.isPickupPhase;
    final isRide = delivery.isRide;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: colors.elevatedCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Route Details",
            style: AppTextStyles.headingSm.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildAddressRow(
            label: isRide ? "PICKUP POINT" : "STORE PICKUP",
            address: delivery.storeAddress.isNotEmpty
                ? delivery.storeAddress
                : (delivery.storeName.isNotEmpty
                      ? delivery.storeName
                      : (isRide ? 'Pickup location' : 'Store pickup')),
            time: "3:42 PM",
            color: isPickupPhase ? AppColors.warning : AppColors.success,
            icon: isRide ? Icons.my_location_rounded : Icons.store_rounded,
            colors: colors,
            isActive: isPickupPhase,
            isCompleted: !isPickupPhase,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Container(width: 1.5, height: 24, color: colors.divider),
          ),
          _buildAddressRow(
            label: isRide ? "DROP-OFF" : "CUSTOMER DROP-OFF",
            address: delivery.customerAddress.isNotEmpty
                ? delivery.customerAddress
                : (isRide ? 'Drop-off location' : 'Customer address'),
            time: "~3:54 PM",
            color: !isPickupPhase
                ? AppColors.primaryAccent
                : colors.textTertiary,
            icon: isRide ? Icons.flag_rounded : Icons.location_on_rounded,
            colors: colors,
            isActive: !isPickupPhase,
            isCompleted: delivery.status == DeliveryStatus.delivered,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow({
    required String label,
    required String address,
    required String time,
    required Color color,
    required IconData icon,
    required C colors,
    required bool isActive,
    required bool isCompleted,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withAlpha(colors.isDark ? 35 : 20),
            shape: BoxShape.circle,
            border: isActive
                ? Border.all(color: color.withAlpha(80), width: 2)
                : null,
          ),
          child: Icon(
            isCompleted ? Icons.check_rounded : icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.overline.copyWith(
                        color: color,
                        fontSize: 10,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs + 2,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: color.withAlpha(colors.isDark ? 30 : 15),
                        borderRadius: AppRadius.pillAll,
                      ),
                      child: Text(
                        "CURRENT",
                        style: AppTextStyles.overline.copyWith(
                          color: color,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: AppTextStyles.bodySm.copyWith(
                  color: isActive ? colors.textPrimary : colors.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: AppTextStyles.caption.copyWith(
            color: colors.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
