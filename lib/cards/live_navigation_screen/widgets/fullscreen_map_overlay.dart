import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:bhukkdelivery/services/map_service.dart';
import 'circle_button.dart';
import 'speed_indicator.dart';
import 'turn_banner.dart';
import 'nav_info_card.dart';

/// Overlay controls shown when the map is in fullscreen navigation mode.
///
/// Includes turn banner, speed indicator, recenter, volume toggle,
/// and the delivery info card. All state is kept in the parent —
/// this widget is purely presentational.
class FullscreenMapOverlay extends StatelessWidget {
  final RouteStep? currentStep;
  final double distToTurn;
  final double speedKmh;
  final bool ttsEnabled;
  final VoidCallback onToggleTts;
  final VoidCallback onToggleTtsResume;
  final VoidCallback onBack;
  final VoidCallback onRecenter;
  final ActiveDelivery delivery;
  final AsyncValue<RouteResult> routeAsync;

  const FullscreenMapOverlay({
    super.key,
    required this.currentStep,
    required this.distToTurn,
    required this.speedKmh,
    required this.ttsEnabled,
    required this.onToggleTts,
    required this.onToggleTtsResume,
    required this.onBack,
    required this.onRecenter,
    required this.delivery,
    required this.routeAsync,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // ─── Turn-by-turn banner ───────────────────────────
        if (currentStep != null)
          Positioned(
            top: top + 8,
            left: 60,
            right: 16,
            child: TurnBanner(
              step: currentStep!,
              liveDistance: distToTurn,
              ttsEnabled: ttsEnabled,
              onToggleTts: onToggleTts,
            ),
          ),

        // ─── Back button ───────────────────────────────────
        Positioned(
          top: top + 8,
          left: 12,
          child: CircleButton(
            icon: Icons.arrow_back_rounded,
            onTap: onBack,
          ),
        ),

        // ─── Speed indicator ───────────────────────────────
        Positioned(
          bottom: 120,
          left: 16,
          child: SpeedIndicator(speedKmh: speedKmh),
        ),

        // ─── Recenter button ───────────────────────────────
        Positioned(
          bottom: 56,
          left: 16,
          child: CircleButton(
            icon: Icons.my_location_rounded,
            onTap: onRecenter,
          ),
        ),

        // ─── Volume toggle ─────────────────────────────────
        Positioned(
          bottom: 120,
          right: 16,
          child: CircleButton(
            icon: ttsEnabled
                ? Icons.volume_up_rounded
                : Icons.volume_off_rounded,
            onTap: onToggleTtsResume,
          ),
        ),

        // ─── Delivery info card ────────────────────────────
        Positioned(
          bottom: 56,
          right: 16,
          child: NavInfoCard(
            delivery: delivery,
            routeAsync: routeAsync,
          ),
        ),
      ],
    );
  }
}
