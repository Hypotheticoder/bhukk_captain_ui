import 'dart:convert';
import 'package:bhukkdelivery/models/route_result.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

export 'package:bhukkdelivery/models/route_result.dart';

/// Top-level function for compute() — must be outside any class.
/// Decodes an encoded polyline string into a list of LatLng on a background isolate.
List<LatLng> _decodePolylineIsolate(String encoded) {
  if (encoded.isEmpty) return const [];
  final polylinePoints = PolylinePoints();
  final decoded = polylinePoints.decodePolyline(encoded);
  return decoded.map((p) => LatLng(p.latitude, p.longitude)).toList();
}

/// Singleton service for Google Maps routing.
/// Fetches routes from the backend `/delivery/get-directions` endpoint
/// which wraps the Google Directions API server-side (keeping the API key secure).
class MapService {
  MapService._();
  static final MapService instance = MapService._();

  String _apiKey = '';
  String _backendBaseUrl = '';

  String get apiKey => _apiKey;
  String get backendBaseUrl => _backendBaseUrl;

  void init() {
    _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
    _backendBaseUrl =
        dotenv.env['BACKEND_BASE_URL'] ?? 'http://192.168.0.222:8000';
    if (_apiKey.isEmpty) {
      debugPrint(
        '⚠️ GOOGLE_MAPS_API_KEY is empty — map tiles will not render.',
      );
    }
  }

  /// Fetch route via Google Directions API directly.
  /// This gives us the full turn-by-turn step data that the backend
  /// endpoint was stripping out (it only returned encoded_polyline +
  /// distance/duration text).
  Future<RouteResult> fetchRoute({
    required LatLng start,
    required LatLng end,
  }) async {
    if (_apiKey.isEmpty) {
      debugPrint('⚠️ No API key — falling back to straight line');
      return _fallbackRoute(start, end);
    }

    final url =
        Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json',
        ).replace(
          queryParameters: {
            'origin': '${start.latitude},${start.longitude}',
            'destination': '${end.latitude},${end.longitude}',
            'mode': 'driving',
            'key': _apiKey,
          },
        );

    debugPrint('📍 [Route] Fetching Google Directions API');

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        debugPrint('❌ Directions API error: ${response.statusCode}');
        return _fallbackRoute(start, end);
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final status = data['status'] as String? ?? '';

      if (status != 'OK') {
        debugPrint('❌ Directions API status: $status');
        return _fallbackRoute(start, end);
      }

      final routes = data['routes'] as List? ?? [];
      if (routes.isEmpty) {
        debugPrint('❌ No routes returned');
        return _fallbackRoute(start, end);
      }

      final route = routes[0] as Map<String, dynamic>;
      final overviewPolyline =
          route['overview_polyline']?['points'] as String? ?? '';
      final legs = route['legs'] as List? ?? [];

      if (overviewPolyline.isEmpty || legs.isEmpty) {
        return _fallbackRoute(start, end);
      }

      // Decode overview polyline on a background isolate
      final geometry = await compute(_decodePolylineIsolate, overviewPolyline);

      debugPrint('📍 [Route] 🔥 DECODED: ${geometry.length} points');

      if (geometry.length < 2) {
        return _fallbackRoute(start, end);
      }

      // Parse leg-level distance/duration
      final leg = legs[0] as Map<String, dynamic>;
      final distanceText = leg['distance']?['text'] as String? ?? '';
      final durationText = leg['duration']?['text'] as String? ?? '';
      final totalDistance =
          (leg['distance']?['value'] as num?)?.toDouble() ?? 0;
      final totalDuration =
          (leg['duration']?['value'] as num?)?.toDouble() ?? 0;

      // Parse turn-by-turn steps
      final rawSteps = leg['steps'] as List? ?? [];
      final steps = <RouteStep>[];

      for (final s in rawSteps) {
        final stepMap = s as Map<String, dynamic>;
        final instruction = (stepMap['html_instructions'] as String? ?? '')
            .replaceAll(RegExp(r'<[^>]*>'), ''); // strip HTML tags
        final maneuver = stepMap['maneuver'] as String? ?? 'straight';
        final stepDist =
            (stepMap['distance']?['value'] as num?)?.toDouble() ?? 0;
        final stepDur =
            (stepMap['duration']?['value'] as num?)?.toDouble() ?? 0;
        final startLoc = stepMap['start_location'] as Map<String, dynamic>?;

        // Determine modifier and type from the maneuver string
        String modifier = 'straight';
        String type = 'turn';

        if (maneuver.contains('left')) {
          modifier = maneuver.contains('sharp')
              ? 'sharp left'
              : maneuver.contains('slight')
              ? 'slight left'
              : 'left';
        } else if (maneuver.contains('right')) {
          modifier = maneuver.contains('sharp')
              ? 'sharp right'
              : maneuver.contains('slight')
              ? 'slight right'
              : 'right';
        } else if (maneuver.contains('uturn') || maneuver.contains('u-turn')) {
          modifier = 'uturn';
        } else if (maneuver.contains('roundabout')) {
          modifier = 'straight';
          type = 'roundabout';
        } else if (maneuver.contains('merge') ||
            maneuver.contains('ramp') ||
            maneuver.contains('fork')) {
          modifier = 'straight';
          type = maneuver;
        }

        steps.add(
          RouteStep(
            instruction: instruction,
            modifier: modifier,
            type: type,
            distance: stepDist,
            duration: stepDur,
            maneuverLocation: startLoc != null
                ? LatLng(
                    (startLoc['lat'] as num).toDouble(),
                    (startLoc['lng'] as num).toDouble(),
                  )
                : start,
          ),
        );
      }

      debugPrint(
        '📍 [Route] ✅ ${geometry.length} pts, '
        '${steps.length} steps, $distanceText, $durationText',
      );

      return RouteResult(
        geometry: geometry,
        steps: steps,
        totalDistance: totalDistance,
        totalDuration: totalDuration,
        distanceText: distanceText,
        durationText: durationText,
      );
    } catch (e) {
      debugPrint('❌ Route fetch failed: $e');
      return _fallbackRoute(start, end);
    }
  }

  /// Fallback: straight line between start and end.
  RouteResult _fallbackRoute(LatLng start, LatLng end) {
    return RouteResult(
      geometry: [start, end],
      steps: [
        RouteStep(
          instruction: 'Head to destination',
          modifier: 'straight',
          type: 'depart',
          distance: 0,
          duration: 0,
          maneuverLocation: start,
        ),
      ],
    );
  }

  /// Decode an encoded polyline string into a list of [LatLng] points.
  /// Uses flutter_polyline_points for robust decoding.
  List<LatLng> decodeEncodedPolyline(String encoded) {
    if (encoded.isEmpty) return const [];
    try {
      final polylinePoints = PolylinePoints();
      final decoded = polylinePoints.decodePolyline(encoded);
      return decoded.map((p) => LatLng(p.latitude, p.longitude)).toList();
    } catch (e) {
      debugPrint('❌ Polyline decode error: $e');
      return const [];
    }
  }

  /// Build LatLngBounds that enclose a list of route points.
  LatLngBounds boundsForRoute(List<LatLng> route) {
    double minLat = route.first.latitude;
    double maxLat = route.first.latitude;
    double minLng = route.first.longitude;
    double maxLng = route.first.longitude;

    for (final p in route) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  /// Build a center point for the route.
  LatLng routeCenter(List<LatLng> route) {
    if (route.isEmpty) return const LatLng(0, 0);
    double sumLat = 0, sumLng = 0;
    for (final p in route) {
      sumLat += p.latitude;
      sumLng += p.longitude;
    }
    return LatLng(sumLat / route.length, sumLng / route.length);
  }
}
