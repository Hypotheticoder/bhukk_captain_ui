import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeliveryTimelineCard extends ConsumerWidget {
  final Animation<double> pulseAnim;

  const DeliveryTimelineCard({super.key, required this.pulseAnim});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = C.of(context);
    final delivery = ref.watch(activeDeliveryProvider);

    if (delivery == null) return const SizedBox.shrink();

    final currentStep = delivery.stepIndex;
    final isRide = delivery.isRide;

    final pickupSteps = isRide
        ? [
            _TimelineStep(
              'Heading to Pickup',
              delivery.storeAddress.isNotEmpty
                  ? delivery.storeAddress
                  : 'Pickup point',
              Icons.directions_rounded,
            ),
            _TimelineStep(
              'Arrived at Pickup',
              'Confirm pickup',
              Icons.my_location_rounded,
            ),
            _TimelineStep(
              'Trip Started',
              'Passenger onboard',
              Icons.directions_car_rounded,
            ),
          ]
        : [
            _TimelineStep(
              'Heading to Store',
              delivery.storeName.isNotEmpty ? delivery.storeName : 'Store',
              Icons.directions_rounded,
            ),
            _TimelineStep(
              'Arrived at Store',
              'Confirm pickup',
              Icons.store_rounded,
            ),
            _TimelineStep(
              'Order Picked Up',
              'Ready to deliver',
              Icons.shopping_bag_rounded,
            ),
          ];

    final deliverySteps = isRide
        ? [
            _TimelineStep(
              'En Route',
              'Heading to destination',
              Icons.navigation_rounded,
            ),
            _TimelineStep('Arriving', 'Almost there', Icons.flag_rounded),
            _TimelineStep(
              'Trip Completed',
              'Complete trip',
              Icons.check_circle_rounded,
            ),
          ]
        : [
            _TimelineStep(
              'En Route',
              'Heading to customer',
              Icons.delivery_dining_rounded,
            ),
            _TimelineStep(
              'Arriving Soon',
              'Almost there',
              Icons.two_wheeler_rounded,
            ),
            _TimelineStep(
              'Delivered',
              'Complete delivery',
              Icons.check_circle_rounded,
            ),
          ];

    final allSteps = [...pickupSteps, ...deliverySteps];

    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: colors.elevatedCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Delivery Progress",
                style: AppTextStyles.headingSm.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.xl),
              ...List.generate(allSteps.length, (i) {
                final step = allSteps[i];
                final isCompleted = i < currentStep;
                final isActive = i == currentStep;

                // Phase divider between pickup (index 2) and delivery (index 3)
                final showPhaseDivider = i == 3;

                return Column(
                  children: [
                    if (showPhaseDivider)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.md,
                          top: AppSpacing.xs,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryAccent.withAlpha(
                                      colors.isDark ? 40 : 20,
                                    ),
                                    AppColors.primaryAccent.withAlpha(
                                      colors.isDark ? 15 : 8,
                                    ),
                                  ],
                                ),
                                borderRadius: AppRadius.pillAll,
                              ),
                              child: Text(
                                "DELIVERY PHASE",
                                style: AppTextStyles.overline.copyWith(
                                  color: AppColors.primaryAccent,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Container(height: 1, color: colors.divider),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 36,
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCompleted || isActive
                                      ? AppColors.primary
                                      : colors.blush.withAlpha(
                                          colors.isDark ? 80 : 150,
                                        ),
                                  boxShadow: isActive
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary.withAlpha(
                                              (80 * pulseAnim.value).toInt(),
                                            ),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Icon(
                                  isCompleted ? Icons.check_rounded : step.icon,
                                  size: 14,
                                  color: isCompleted || isActive
                                      ? Colors.white
                                      : colors.textTertiary,
                                ),
                              ),
                              if (i < allSteps.length - 1)
                                Container(
                                  width: 2,
                                  height: 36,
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? AppColors.primary.withAlpha(100)
                                        : colors.blush.withAlpha(
                                            colors.isDark ? 50 : 100,
                                          ),
                                    borderRadius: AppRadius.pillAll,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: i < allSteps.length - 1 ? AppSpacing.md : 0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  step.title,
                                  style: AppTextStyles.bodyMd.copyWith(
                                    fontWeight: isActive
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isActive
                                        ? colors.textPrimary
                                        : isCompleted
                                        ? colors.textSecondary
                                        : colors.textTertiary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  step.subtitle,
                                  style: AppTextStyles.caption.copyWith(
                                    color: colors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
              // Phase label at the top for pickup phase
              if (currentStep < 3)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs + 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withAlpha(colors.isDark ? 25 : 12),
                      borderRadius: AppRadius.pillAll,
                      border: Border.all(
                        color: AppColors.warning.withAlpha(colors.isDark ? 40 : 25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isRide ? Icons.my_location_rounded : Icons.store_rounded,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          isRide ? 'Pickup Phase' : 'Store Pickup Phase',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (currentStep >= 3)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs + 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(colors.isDark ? 25 : 12),
                      borderRadius: AppRadius.pillAll,
                      border: Border.all(
                        color: AppColors.success.withAlpha(colors.isDark ? 40 : 25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.delivery_dining_rounded,
                          size: 14,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          "Customer Delivery Phase",
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TimelineStep {
  final String title;
  final String subtitle;
  final IconData icon;

  _TimelineStep(this.title, this.subtitle, this.icon);
}
