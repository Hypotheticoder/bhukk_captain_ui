import 'package:flutter/material.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:bhukkdelivery/services/map_service.dart';

class TurnBanner extends StatelessWidget {
  final RouteStep step;
  final double liveDistance; // M ineters
  final bool ttsEnabled;
  final VoidCallback onToggleTts;

  const TurnBanner({
    super.key,
    required this.step,
    required this.liveDistance,
    required this.ttsEnabled,
    required this.onToggleTts,
  });

  IconData _getManeuverIcon(String modifier, String type) {
    if (type == 'arrive') return Icons.flag_rounded;
    if (type == 'depart') return Icons.navigation_rounded;
    switch (modifier) {
      case 'left':
        return Icons.turn_left_rounded;
      case 'right':
        return Icons.turn_right_rounded;
      case 'sharp left':
        return Icons.turn_sharp_left_rounded;
      case 'sharp right':
        return Icons.turn_sharp_right_rounded;
      case 'slight left':
        return Icons.turn_slight_left_rounded;
      case 'slight right':
        return Icons.turn_slight_right_rounded;
      case 'uturn':
        return Icons.u_turn_left_rounded;
      case 'straight':
      default:
        return Icons.straight_rounded;
    }
  }

  String get _formattedDistance {
    if (liveDistance >= 1000) {
      return '${(liveDistance / 1000).toStringAsFixed(1)} km';
    }
    return '${liveDistance.toInt()} m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A73E8),
        borderRadius: AppRadius.xlAll,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: AppRadius.mdAll,
            ),
            child: Icon(
              _getManeuverIcon(step.modifier, step.type),
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formattedDistance,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  step.shortDirection,
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggleTts,
            child: Icon(
              ttsEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: Colors.white.withAlpha(180),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
