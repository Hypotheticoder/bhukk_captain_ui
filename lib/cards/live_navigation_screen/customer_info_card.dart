import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows store info during pickup phase, customer info during delivery phase.
class ContactInfoCard extends ConsumerWidget {
  const ContactInfoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = C.of(context);
    final delivery = ref.watch(activeDeliveryProvider);

    if (delivery == null) return const SizedBox.shrink();

    final isPickup = delivery.isPickupPhase;
    final isRide = delivery.isRide;

    final name = isRide
        ? (delivery.dropName.isNotEmpty
            ? delivery.dropName
            : delivery.customerName)
        : (isPickup
            ? (delivery.pickupName.isNotEmpty
                ? delivery.pickupName
                : delivery.storeName)
            : (delivery.dropName.isNotEmpty
                ? delivery.dropName
                : delivery.customerName));

    final phone = isRide
        ? (delivery.dropPhone.isNotEmpty
            ? delivery.dropPhone
            : delivery.pickupPhone)
        : (isPickup ? delivery.pickupPhone : delivery.dropPhone);

    final subtitle = isRide
        ? (isPickup
              ? (delivery.storeAddress.isNotEmpty
                    ? delivery.storeAddress
                    : 'Pickup point')
              : (delivery.customerAddress.isNotEmpty
                    ? delivery.customerAddress
                    : 'Drop-off'))
        : (isPickup
              ? (delivery.storeAddress.isNotEmpty
                    ? delivery.storeAddress
                    : 'Pickup location')
              : "${delivery.customerAddress.isNotEmpty ? delivery.customerAddress : 'Drop-off'} • ${delivery.items.split(',').length} items");
    final initials = name.isNotEmpty
        ? name
              .split(' ')
              .take(2)
              .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
              .join()
        : '?';
    final gradientColors = isRide
        ? [AppColors.primary, AppColors.primaryAccent]
        : (isPickup
              ? [AppColors.warning, AppColors.starYellow]
              : [AppColors.primary, AppColors.primaryAccent]);

    final contactLabel = isRide
        ? 'Passenger'
        : (isPickup ? 'Sender/Store' : 'Receiver');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: colors.elevatedCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phase label
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(
              "$contactLabel Contact",
              style: AppTextStyles.overline.copyWith(
                color: colors.textTertiary,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: gradientColors),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withAlpha(40),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: isRide
                      ? const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 22,
                        )
                      : (isPickup
                            ? const Icon(
                                Icons.store_rounded,
                                color: Colors.white,
                                size: 22,
                              )
                            : Text(
                                initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              )),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: colors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (phone.isNotEmpty) {
                    final uri = Uri.parse('tel:$phone');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not launch dialer')),
                        );
                      }
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('No phone number for $contactLabel')),
                      );
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm + 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(colors.isDark ? 40 : 20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone_rounded,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm + 4),
                  decoration: BoxDecoration(
                    color: AppColors.info.withAlpha(colors.isDark ? 40 : 20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppColors.info,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
