import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:bhukkdelivery/services/map_service.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'circle_button.dart';
import 'live_badge.dart';
import 'phase_badge.dart';
import 'eta_overlay.dart';

/// Overlay controls shown when the map is in compact (non-fullscreen) mode.
///
/// Includes a gradient scrim, live badge, phase badge, fullscreen button,
/// and the ETA overlay. Purely presentational — all state is in the parent.
class CompactMapOverlay extends StatelessWidget {
  final Animation<double> pulseAnim;
  final ActiveDelivery delivery;
  final AsyncValue<RouteResult>? routeAsync;
  final VoidCallback onToggleFullscreen;

  const CompactMapOverlay({
    super.key,
    required this.pulseAnim,
    required this.delivery,
    required this.routeAsync,
    required this.onToggleFullscreen,
  });

  Future<void> _openMapsNavigation(BuildContext context) async {
    final isPickup = delivery.isPickupPhase;
    final lat = isPickup ? delivery.pickupLocation.latitude : delivery.dropoffLocation.latitude;
    final lng = isPickup ? delivery.pickupLocation.longitude : delivery.dropoffLocation.longitude;

    Uri url;
    if (Platform.isAndroid) {
      url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
    } else {
      url = Uri.parse('https://maps.apple.com/?daddr=$lat,$lng&dirflg=d');
    }

    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open Maps")));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error opening Maps: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    final top = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // ─── Gradient scrim ────────────────────────────────
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.background.withAlpha(100),
                    Colors.transparent,
                    Colors.transparent,
                    colors.background.withAlpha(140),
                  ],
                  stops: const [0.0, 0.2, 0.7, 1.0],
                ),
              ),
            ),
          ),
        ),

        // ─── Live badge ────────────────────────────────────
        Positioned(
          top: top + 10,
          right: 16,
          child: LiveBadge(pulseAnim: pulseAnim),
        ),

        // ─── Phase badge ───────────────────────────────────
        Positioned(
          top: top + 10,
          left: 60,
          child: PhaseBadge(delivery: delivery),
        ),

        // ─── Fullscreen button (Commented out) ─────────────
        /*
        Positioned(
          bottom: 16,
          left: 16,
          child: CircleButton(
            icon: Icons.fullscreen_rounded,
            onTap: onToggleFullscreen,
          ),
        ),
        */

        // ─── Map Navigation Button ─────────────────────────
        Positioned(
          bottom: 16,
          left: 16,
          child: CircleButton(
            icon: Icons.navigation_rounded,
            onTap: () => _openMapsNavigation(context),
            backgroundColor: AppColors.success,
            iconColor: Colors.white,
          ),
        ),

        // ─── ETA overlay ───────────────────────────────────
        Positioned(
          bottom: 16,
          right: 16,
          child: EtaOverlay(
            delivery: delivery,
            routeAsync: routeAsync,
          ),
        ),
      ],
    );
  }
}
