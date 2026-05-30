import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Singleton service that wraps Geolocator + permission_handler for
/// requesting location permission, getting the current position, and
/// streaming live location updates (useful for delivery tracking).
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  StreamSubscription<Position>? _positionSub;

  // ─── Permission ────────────────────────────────────────────

  /// Request location permission (when-in-use first, then always if needed).
  /// Returns `true` when at least when-in-use permission is granted.
  Future<bool> requestPermission() async {
    // 1. Check if location services are enabled on the device.
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Optionally open location settings.
      await Geolocator.openLocationSettings();
      return false;
    }

    // 2. Request when-in-use permission.
    var status = await Permission.locationWhenInUse.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      return false;
    }

    return true;
  }

  /// Request background (always) location — call only after
  /// when-in-use has already been granted.
  Future<bool> requestBackgroundPermission() async {
    final status = await Permission.locationAlways.request();
    return status.isGranted;
  }

  /// `true` when at least when-in-use is granted.
  Future<bool> get hasPermission async {
    final status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  // ─── Current position ──────────────────────────────────────

  /// One-shot current position (high accuracy).
  Future<Position?> getCurrentPosition() async {
    if (!await hasPermission) {
      final ok = await requestPermission();
      if (!ok) return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    );
  }

  // ─── Live tracking stream ──────────────────────────────────

  /// Start streaming location updates.
  /// Calls [onPosition] every time a new position arrives.
  /// Calls [onError] on failure (optional).
  void startTracking({
    required void Function(Position position) onPosition,
    void Function(Object error)? onError,
    int distanceFilterMeters = 10,
  }) {
    stopTracking(); // cancel any existing subscription

    final settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: distanceFilterMeters,
    );

    _positionSub = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen(onPosition, onError: onError);
  }

  /// Stop the live tracking stream.
  void stopTracking() {
    _positionSub?.cancel();
    _positionSub = null;
  }

  // ─── Utilities ─────────────────────────────────────────────

  /// Distance in metres between two geo-points.
  double distanceBetween({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}
