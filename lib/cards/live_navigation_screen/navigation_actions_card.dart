import 'package:bhukkdelivery/cards/live_navigation_screen/cancel_order_dialog.dart';
import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigationActionsCard extends ConsumerWidget {
  const NavigationActionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = C.of(context);
    final delivery = ref.watch(activeDeliveryProvider);

    if (delivery == null) return const SizedBox.shrink();

    // Determine which location to navigate to based on phase
    final requiresOtp = delivery.requiresOtp;

    // Cancel is only allowed before driver arrives (heading to store phase)
    final canCancel = delivery.status == DeliveryStatus.headingToStore;

    return Column(
      children: [
        // Primary action — advance status or navigate to OTP
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();

            final isArriving = delivery.status == DeliveryStatus.arriving;
            final needsPayment = isArriving && delivery.isCashOnDelivery && delivery.isPaymentPending;

            if (needsPayment) {
              // COD order → show checkout screen to collect cash BEFORE 2nd OTP
              context.push(
                Uri(
                  path: '/payment',
                  queryParameters: {
                    'serviceType': delivery.serviceType,
                    'amount': delivery.orderAmount.toString(),
                    'orderId': delivery.orderId,
                  },
                ).toString(),
              );
              return;
            }

            if (requiresOtp) {
              // Navigate to OTP screen for verification
              context.push('/home/live_navigation/otp');
              return;
            }

            final isLastStep = delivery.status == DeliveryStatus.delivered;

            if (isLastStep) {
              // Payment is already collected (either prepaid, or COD collected earlier in arriving phase)
              ref.read(activeDeliveryProvider.notifier).completeDelivery();
            } else {
              // If the button is "Start Navigation" or "Start Delivery", open maps
              final label = delivery.actionButtonLabel.toLowerCase();
              if (label.contains('start') || label.contains('navigation')) {
                final target = delivery.isPickupPhase
                    ? delivery.pickupLocation
                    : delivery.dropoffLocation;

                final mapUrl =
                    'https://www.google.com/maps/dir/?api=1&destination=${target.latitude},${target.longitude}&travelmode=driving';
                launchUrl(Uri.parse(mapUrl),
                    mode: LaunchMode.externalApplication);
              }

              ref.read(activeDeliveryProvider.notifier).advanceStatus();
            }
          },
          child: Container(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: requiresOtp
                    ? [AppColors.primary, AppColors.primaryAccent]
                    : [AppColors.primary, AppColors.primaryAccent],
              ),
              borderRadius: AppRadius.pillAll,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(100),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (requiresOtp) ...[
                    const Icon(
                      Icons.lock_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    delivery.actionButtonLabel,
                    style: AppTextStyles.buttonText.copyWith(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Cancel Order Button — only before first OTP ──
        if (canCancel) ...[
          const SizedBox(height: AppSpacing.lg),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              showCancelOrderDialog(context, ref);
            },
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: AppRadius.pillAll,
                border: Border.all(
                  color: AppColors.error.withAlpha(colors.isDark ? 80 : 60),
                  width: 1.5,
                ),
                color: AppColors.error.withAlpha(colors.isDark ? 15 : 8),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cancel_outlined,
                      color: AppColors.error.withAlpha(200),
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Cancel Order',
                      style: AppTextStyles.buttonText.copyWith(
                        color: AppColors.error.withAlpha(200),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
