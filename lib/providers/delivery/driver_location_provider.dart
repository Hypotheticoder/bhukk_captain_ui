import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_compass/flutter_compass.dart';

/// Holds both GPS position and speed from a single stream.
class DriverLocation {
  final LatLng position;
  final double speed; // m/s from Geolocator
  final double heading; // degrees (0-360) from Geolocator
  final double accuracy; // meters – horizontal accuracy
  final LatLng? previousPosition; // previous GPS fix for delta computation

  const DriverLocation({
    required this.position,
    this.speed = 0,
    this.heading = 0,
    this.accuracy = 0,
    this.previousPosition,
  });
}

/// Unified provider: single GPS stream for both position AND speed.
/// Requests location permission on first access, then streams updates.
class DriverLocationNotifier extends Notifier<DriverLocation?> {
  StreamSubscription<geo.Position>? _positionStream;
  StreamSubscription<CompassEvent>? _compassStream;
  double _currentHeading = 0.0;

  @override
  DriverLocation? build() {
    _initLocation();
    ref.onDispose(() {
      _positionStream?.cancel();
      _compassStream?.cancel();
    });
    return null;
  }

  Future<void> _initLocation() async {
    final ok = await _ensurePermission();
    if (!ok) return;

    // Get initial position quickly
    try {
      final initialPos = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.bestForNavigation,
        ),
      );
      state = DriverLocation(
        position: LatLng(initialPos.latitude, initialPos.longitude),
        speed: initialPos.speed >= 0 ? initialPos.speed : 0,
        heading: initialPos.heading >= 0 ? initialPos.heading : 0,
        accuracy: initialPos.accuracy >= 0 ? initialPos.accuracy : 0,
      );
    } catch (_) {}

    // Single live tracking stream — provides both position and speed
    _compassStream = FlutterCompass.events?.listen((event) {
      if (event.heading != null) {
        _currentHeading = event.heading!;
        // Push the new heading immediately if we already have a GPS fix
        if (state != null) {
          state = DriverLocation(
            position: state!.position,
            speed: state!.speed,
            heading: _currentHeading,
            accuracy: state!.accuracy,
            previousPosition: state!.previousPosition,
          );
        }
      }
    });

    _positionStream =
        geo.Geolocator.getPositionStream(
          locationSettings: const geo.LocationSettings(
            accuracy: geo.LocationAccuracy.bestForNavigation,
            distanceFilter: 1, // 1 m for pin-point navigation accuracy
          ),
        ).listen((geo.Position pos) {
          final prevPos = state?.position;
          state = DriverLocation(
            position: LatLng(pos.latitude, pos.longitude),
            speed: pos.speed >= 0 ? pos.speed : 0,
            heading: _currentHeading, // Rely on real device gyro compass
            accuracy: pos.accuracy >= 0 ? pos.accuracy : 0,
            previousPosition: prevPos,
          );
        });
  }

  /// Check & request location permission + service.
  Future<bool> _ensurePermission() async {
    bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    geo.LocationPermission permission = await geo.Geolocator.checkPermission();

    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) return false;
    }

    if (permission == geo.LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }
}

/// Single unified provider — emits DriverLocation with both position and speed.
final driverLocationProvider =
    NotifierProvider<DriverLocationNotifier, DriverLocation?>(() {
      return DriverLocationNotifier();
    });
