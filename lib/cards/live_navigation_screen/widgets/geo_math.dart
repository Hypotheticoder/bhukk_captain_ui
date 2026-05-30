import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Pure static geo-math utilities used by the navigation engine.
abstract final class GeoMath {
  /// Haversine distance between two points in metres.
  static double haversine(LatLng a, LatLng b) {
    const R = 6371000.0;
    final lat1 = a.latitude * math.pi / 180;
    final lat2 = b.latitude * math.pi / 180;
    final dLat = (b.latitude - a.latitude) * math.pi / 180;
    final dLng = (b.longitude - a.longitude) * math.pi / 180;
    final h =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return R * 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
  }

  /// Minimum distance from [p] to any segment of [poly].
  static double distToPolyline(LatLng p, List<LatLng> poly) {
    if (poly.isEmpty) return double.infinity;
    if (poly.length == 1) return haversine(p, poly.first);
    double best = double.infinity;
    for (int i = 0; i < poly.length - 1; i++) {
      final d = ptSegDist(p, poly[i], poly[i + 1]);
      if (d < best) best = d;
    }
    return best;
  }

  /// Distance from [p] to segment [a]→[b].
  static double ptSegDist(LatLng p, LatLng a, LatLng b) {
    final px = p.longitude, py = p.latitude;
    final ax = a.longitude, ay = a.latitude;
    final bx = b.longitude, by = b.latitude;
    final dx = bx - ax, dy = by - ay;
    final lenSq = dx * dx + dy * dy;
    if (lenSq == 0) return haversine(p, a);
    final t = ((px - ax) * dx + (py - ay) * dy) / lenSq;
    final ct = t.clamp(0.0, 1.0);
    return haversine(p, LatLng(ay + ct * dy, ax + ct * dx));
  }

  /// Remaining route distance (metres) from [driver] along [poly].
  static double remainingDist(LatLng driver, List<LatLng> poly) {
    if (poly.length < 2) return 0;
    int closestIdx = 0;
    double minDist = double.infinity, closestT = 0;
    for (int i = 0; i < poly.length - 1; i++) {
      final ax = poly[i].longitude, ay = poly[i].latitude;
      final bx = poly[i + 1].longitude, by = poly[i + 1].latitude;
      final dx = bx - ax, dy = by - ay;
      final lenSq = dx * dx + dy * dy;
      double t = 0;
      if (lenSq > 0) {
        t = ((driver.longitude - ax) * dx + (driver.latitude - ay) * dy) /
            lenSq;
        t = t.clamp(0.0, 1.0);
      }
      final d = haversine(driver, LatLng(ay + t * dy, ax + t * dx));
      if (d < minDist) {
        minDist = d;
        closestIdx = i;
        closestT = t;
      }
    }
    double rem =
        haversine(poly[closestIdx], poly[closestIdx + 1]) * (1 - closestT);
    for (int i = closestIdx + 1; i < poly.length - 1; i++) {
      rem += haversine(poly[i], poly[i + 1]);
    }
    return rem;
  }
}
