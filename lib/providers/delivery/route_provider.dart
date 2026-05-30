import 'package:bhukkdelivery/services/map_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Cache key for route fetching: "startLat,startLng;endLat,endLng"
typedef RouteKey = String;

/// Builds a cache key from two LatLng positions.
String routeKey(LatLng start, LatLng end) =>
    '${start.latitude},${start.longitude};${end.latitude},${end.longitude}';

/// FutureProvider that fetches the Google Directions route once per key.
/// Returns a RouteResult containing geometry and distance/duration info.
final routeProvider = FutureProvider.family<RouteResult, RouteKey>((
  ref,
  key,
) async {
  final parts = key.split(';');
  final startParts = parts[0].split(',');
  final endParts = parts[1].split(',');

  final start = LatLng(
    double.parse(startParts[0]),
    double.parse(startParts[1]),
  );
  final end = LatLng(double.parse(endParts[0]), double.parse(endParts[1]));

  return MapService.instance.fetchRoute(start: start, end: end);
});
