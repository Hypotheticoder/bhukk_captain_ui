import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A single maneuver step from the Directions API.
class RouteStep {
  final String instruction;
  final String modifier; // e.g. "left", "right", "straight"
  final String type; // e.g. "turn", "depart", "arrive"
  final double distance; // meters
  final double duration; // seconds
  final LatLng maneuverLocation;

  const RouteStep({
    required this.instruction,
    required this.modifier,
    required this.type,
    required this.distance,
    required this.duration,
    required this.maneuverLocation,
  });

  /// Human-readable short direction for the banner.
  String get shortDirection {
    if (type == 'arrive') return 'Arrive';
    if (type == 'depart') return 'Depart';
    switch (modifier) {
      case 'left':
        return 'Turn Left';
      case 'right':
        return 'Turn Right';
      case 'sharp left':
        return 'Sharp Left';
      case 'sharp right':
        return 'Sharp Right';
      case 'slight left':
        return 'Slight Left';
      case 'slight right':
        return 'Slight Right';
      case 'uturn':
        return 'U-Turn';
      case 'straight':
      default:
        return 'Continue';
    }
  }

  /// Distance formatted as human-readable string.
  String get distanceText {
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
    return '${distance.toInt()} m';
  }
}

/// Result from fetching a route: geometry + turn-by-turn steps.
class RouteResult {
  final List<LatLng> geometry;
  final List<RouteStep> steps;
  final double totalDistance; // meters
  final double totalDuration; // seconds
  final String distanceText; // human-readable from backend (e.g. "3.2 km")
  final String durationText; // human-readable from backend (e.g. "12 mins")

  const RouteResult({
    required this.geometry,
    required this.steps,
    this.totalDistance = 0,
    this.totalDuration = 0,
    this.distanceText = '',
    this.durationText = '',
  });

  bool get isEmpty => geometry.isEmpty;
  bool get isNotEmpty => geometry.isNotEmpty;
}
