import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'geo_math.dart';

/// Encapsulates the route-progress trimming logic.
///
/// As the driver moves along the route, this class finds the closest
/// segment, snaps to it, and returns the remaining polyline points
/// ahead of the driver. This avoids redrawing the whole route on
/// every GPS tick and gives the "shrinking route" visual effect.
class RouteTrimmer {
  LatLng? _lastTrimPos;
  bool _isTrimming = false;
  int _lastTrimSegmentIdx = 0;

  /// Reset internal state when the route or phase changes.
  void reset() {
    _lastTrimPos = null;
    _lastTrimSegmentIdx = 0;
  }

  /// Trims [routeGeometry] so only the portion ahead of [driverPos]
  /// remains. Returns the trimmed list, or `null` if no trim is needed
  /// (driver hasn't moved far enough, or the geometry is too short).
  List<LatLng>? trim(LatLng driverPos, List<LatLng> routeGeometry) {
    if (routeGeometry.length < 2) return null;
    if (_isTrimming) return null;

    // Skip if the driver hasn't moved ≥ 5 m since last trim
    if (_lastTrimPos != null &&
        GeoMath.haversine(driverPos, _lastTrimPos!) < 5) {
      return null;
    }

    _isTrimming = true;
    _lastTrimPos = driverPos;

    try {
      int closestIdx = _lastTrimSegmentIdx;
      double minDist = double.infinity;
      double closestT = 0;

      // Narrow window search first (cheap)
      final searchStart = math.max(0, _lastTrimSegmentIdx - 2);
      final searchEnd = math.min(
        routeGeometry.length - 1,
        _lastTrimSegmentIdx + 20,
      );

      for (int i = searchStart; i < searchEnd; i++) {
        final res = _snapToSegment(driverPos, routeGeometry, i);
        if (res.distance < minDist) {
          minDist = res.distance;
          closestIdx = i;
          closestT = res.t;
        }
      }

      // Fallback to full scan if narrow window missed
      if (minDist > 100) {
        for (int i = 0; i < routeGeometry.length - 1; i++) {
          final res = _snapToSegment(driverPos, routeGeometry, i);
          if (res.distance < minDist) {
            minDist = res.distance;
            closestIdx = i;
            closestT = res.t;
          }
        }
      }

      _lastTrimSegmentIdx = closestIdx;

      final a = routeGeometry[closestIdx];
      final b = routeGeometry[closestIdx + 1];
      final snapLat = a.latitude + closestT * (b.latitude - a.latitude);
      final snapLng = a.longitude + closestT * (b.longitude - a.longitude);

      final remaining = <LatLng>[
        driverPos,
        LatLng(snapLat, snapLng),
        ...routeGeometry.sublist(closestIdx + 1),
      ];

      if (remaining.length < 2) return null;
      return remaining;
    } finally {
      _isTrimming = false;
    }
  }

  /// Haversine-based snap-to-segment projection.
  ({double t, double distance}) _snapToSegment(
    LatLng driverPos,
    List<LatLng> geometry,
    int segIdx,
  ) {
    final a = geometry[segIdx];
    final b = geometry[segIdx + 1];
    final ax = a.longitude, ay = a.latitude;
    final bx = b.longitude, by = b.latitude;

    final cosLat = math.cos((ay + by) / 2 * math.pi / 180);
    final dxSeg = (bx - ax) * cosLat;
    final dySeg = by - ay;
    final lenSq = dxSeg * dxSeg + dySeg * dySeg;

    double t = 0;
    if (lenSq > 0) {
      final dxP = (driverPos.longitude - ax) * cosLat;
      final dyP = driverPos.latitude - ay;
      t = (dxP * dxSeg + dyP * dySeg) / lenSq;
      t = t.clamp(0.0, 1.0);
    }

    final projLng = ax + t * (bx - ax);
    final projLat = ay + t * (by - ay);
    final dist = GeoMath.haversine(driverPos, LatLng(projLat, projLng));
    return (t: t, distance: dist);
  }
}
