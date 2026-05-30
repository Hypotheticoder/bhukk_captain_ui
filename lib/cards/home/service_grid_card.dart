import 'package:bhukkdelivery/notifiers/home_screen/master_dashboard_notifier.dart';
import 'package:bhukkdelivery/providers/home/master_dashboard_provider.dart';
import 'package:bhukkdelivery/cards/home/new_order_popup_helper.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A layout of modern service tiles for Parcel, Cab Booking, and Medicine
/// without background images, using a solid clean design.
class ServiceGridCard extends ConsumerWidget {
  const ServiceGridCard({super.key});

  /// Maps a serviceId to a short subtitle.
  static String _subtitleForService(String serviceId) {
    switch (serviceId) {
      case 'car_booking':
        return 'Ride requests';
      case 'parcel':
        return 'Parcel pickups';
      case 'medicine':
        return 'Pharmacy pickups';
      default:
        return 'Service orders';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(masterDashboardProvider);
    final colors = C.of(context);

    // Grab the services specifically if they are available
    final cabService = dashboardState.services.where((s) => s.serviceId == 'car_booking').firstOrNull;
    final parcelService = dashboardState.services.where((s) => s.serviceId == 'parcel').firstOrNull;
    final medicineService = dashboardState.services.where((s) => s.serviceId == 'medicine').firstOrNull;

    // Create a list of available top row services
    final topRowServices = [parcelService, cabService].where((s) => s != null).cast<ServiceSummary>().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your Services",
          style: AppTextStyles.headingSm.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.md),
        
        // TOP ROW: Parcel and Cab (side-by-side)
        if (topRowServices.isNotEmpty) ...[
          Row(
            children: [
              for (int i = 0; i < topRowServices.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _ServiceTile(
                    service: topRowServices[i],
                    index: i,
                    subtitle: _subtitleForService(topRowServices[i].serviceId),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // BOTTOM ROW: Medicine (full width)
        if (medicineService != null) ...[
          SizedBox(
            width: double.infinity,
            child: _ServiceTile(
              service: medicineService,
              index: topRowServices.length,
              subtitle: _subtitleForService(medicineService.serviceId),
            ),
          ),
        ],
      ],
    );
  }
}

class _ServiceTile extends ConsumerWidget {
  final ServiceSummary service;
  final int index;
  final String subtitle;

  const _ServiceTile({
    required this.service,
    required this.index,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = C.of(context);
    final serviceColor = service.color;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + index * 100),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.5 + (0.5 * value),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: GestureDetector(
        onTap: () => context.push(service.route),
        child: Container(
          height: 160,
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.isDark ? serviceColor.withAlpha(20) : serviceColor.withAlpha(15),
            borderRadius: AppRadius.xlAll,
            border: Border.all(
              color: service.isOnline
                  ? serviceColor.withAlpha(120)
                  : colors.divider.withAlpha(60),
              width: service.isOnline ? 1.5 : 1.0,
            ),
            boxShadow: [
              if (service.isOnline)
                BoxShadow(
                  color: serviceColor.withAlpha(colors.isDark ? 20 : 12),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Icon ──
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: serviceColor.withAlpha(colors.isDark ? 30 : 25),
                      borderRadius: AppRadius.mdAll,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          service.icon,
                          size: 28,
                          color: serviceColor,
                        ),
                        if (service.secondaryIcon != null) ...[
                          const SizedBox(width: AppSpacing.sm / 2),
                          Icon(
                            service.secondaryIcon,
                            size: 24, // slightly smaller
                            color: serviceColor,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Spacer(),
                  // ── Service name & Subtitle ──
                  Text(
                    service.name,
                    style: AppTextStyles.label.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: colors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // ── Status + Toggle row ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: service.isOnline
                              ? AppColors.success.withAlpha(20)
                              : colors.blush.withAlpha(60),
                          borderRadius: AppRadius.pillAll,
                          border: Border.all(
                            color: service.isOnline
                                ? AppColors.success.withAlpha(50)
                                : colors.divider.withAlpha(40),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: service.isOnline
                                    ? AppColors.success
                                    : colors.textTertiary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              service.isOnline ? "Online" : "Offline",
                              style: AppTextStyles.overline.copyWith(
                                color: service.isOnline
                                    ? AppColors.success
                                    : colors.textTertiary,
                                fontSize: 10,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Toggle
                      GestureDetector(
                        onTap: () {
                          final isNowOnline = ref
                              .read(masterDashboardProvider.notifier)
                              .toggleServiceById(service.serviceId);
                          if (isNowOnline) {
                            Future.delayed(
                              const Duration(milliseconds: 600),
                              () {
                                if (!context.mounted) return;
                                showNewOrderPopup(
                                  context,
                                  ref,
                                  service.serviceId,
                                );
                              },
                            );
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 44,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: service.isOnline
                                ? LinearGradient(
                                    colors: [
                                      serviceColor.withAlpha(200),
                                      serviceColor,
                                    ],
                                  )
                                : null,
                            color: service.isOnline
                                ? null
                                : Colors.grey.withAlpha(60),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            alignment: service.isOnline
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(25),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // ── Top-right glow indicator when online ──
              if (service.isOnline)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: serviceColor,
                      boxShadow: [
                        BoxShadow(
                          color: serviceColor.withAlpha(120),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
