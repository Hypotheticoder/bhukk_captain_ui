import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Builds the 3-layer Google Maps polyline set (border → outline → core)
/// that gives the route line a premium, embossed look.
abstract final class RoutePolylineBuilder {
  /// Creates a [Set<Polyline>] with border, white outline, and core colour.
  /// [isPickup] controls the palette (warm orange vs Google blue).
  static Set<Polyline> build(
    List<LatLng> points, {
    required bool isPickup,
  }) {
    if (points.length < 2) return {};

    // Pickup = warm orange · Delivery = Google blue
    final Color borderColor =
        isPickup ? const Color(0xFFBF360C) : const Color(0xFF1565C0);
    final Color coreColor =
        isPickup ? const Color(0xFFFFA726) : const Color(0xFF4285F4);

    return {
      // Border (widest, rendered under core)
      Polyline(
        polylineId: const PolylineId('route-border'),
        points: points,
        color: borderColor,
        width: 10,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
      // White outline
      Polyline(
        polylineId: const PolylineId('route-outline'),
        points: points,
        color: Colors.white,
        width: 7,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
      // Core route line
      Polyline(
        polylineId: const PolylineId('route-core'),
        points: points,
        color: coreColor,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    };
  }
}
