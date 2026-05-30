import 'dart:async';
import 'dart:convert';
import 'package:bhukkdelivery/services/api/api_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Service that streams the driver's live GPS location to the
/// Parcel Backend's WebSocket tracking room so the customer can
/// see the driver moving on their map in real-time.
///
/// Usage:
///   final tracking = LiveTrackingService();
///   await tracking.startTracking(bridgeId);  // after accept
///   tracking.stopTracking();                 // after delivery
class LiveTrackingService {
  LiveTrackingService._();
  static final LiveTrackingService instance = LiveTrackingService._();

  WebSocketChannel? _channel;
  StreamSubscription<Position>? _positionStream;
  StreamController<Map<String, dynamic>>? _eventStreamController;
  bool _isTracking = false;

  /// Stream of incoming events from the tracking room (e.g. CUSTOMER_CANCELLED).
  Stream<Map<String, dynamic>> get eventStream {
    _eventStreamController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _eventStreamController!.stream;
  }

  bool get isTracking => _isTracking;

  /// Start streaming the driver's GPS into the customer's tracking room.
  ///
  /// [bridgeId] is the `external_order_id` from the DispatchJob,
  /// which maps to the `customer_orders.id` on the Parcel Backend.
  Future<void> startTracking(String bridgeId) async {
    if (_isTracking) return;

    // 1. Check / request location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('❌ Location permission denied — tracking not started.');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      debugPrint('❌ Location permission permanently denied — cannot track.');
      return;
    }

    // 2. Connect to the Parcel Backend's WebSocket tracking room via the Driver WS gateway
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken() ?? '';
    final wsUrl = Uri.parse(
      '${ApiConfig.wsBaseUrl}/drivers/ws/location/$bridgeId?token=$token',
    );

    try {
      _channel = WebSocketChannel.connect(wsUrl);
      await _channel!.ready;
      debugPrint('🔌 Connected to tracking room on driver backend: $bridgeId');

      _channel!.stream.listen(
        (message) {
          debugPrint('🔵 [WS] Message from Backend: $message');
          try {
            final data = jsonDecode(message.toString());
            if (data is Map<String, dynamic>) {
              debugPrint('🔵 [WS] Parsed Event: ${data['event']}');
              _eventStreamController?.add(data);
            }
          } catch (e) {
            debugPrint('⚠️ [WS] JSON Parse Error: $e');
          }
        },
        onError: (err) {
          debugPrint('🔴 [WS] Connection Error: $err');
          _eventStreamController?.add({'event': 'WS_ERROR', 'error': err.toString()});
        },
        onDone: () {
          debugPrint(
            '⚫ [WS] Connection Closed. Code: ${_channel!.closeCode}, Reason: ${_channel!.closeReason}',
          );
          _isTracking = false;
          _eventStreamController?.add({'event': 'WS_CLOSED'});
        },
      );

      _isTracking = true;

      // Send initial location immediately upon connection!
      // This ensures the customer map renders the driver instantly
      try {
        Position? initialPos = await Geolocator.getLastKnownPosition();
        initialPos ??= await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 3),
          ),
        );
        final initialData = {
          'event': 'LOCATION_UPDATE',
          'lat': initialPos.latitude,
          'lng': initialPos.longitude,
          'speed': initialPos.speed,
          'heading': initialPos.heading,
        };
        _channel?.sink.add(jsonEncode(initialData));
        debugPrint(
          '📍 Initial GPS → server: ${initialPos.latitude.toStringAsFixed(5)}, ${initialPos.longitude.toStringAsFixed(5)}',
        );
      } catch (e) {
        debugPrint(
          '⚠️ Could not fetch initial GPS (Emulator Issue?). Sending FAKE GPS fallback: $e',
        );
        final fakeData = {
          'event': 'LOCATION_UPDATE',
          'lat': 22.48600, // Safe static coordinate
          'lng': 88.37800,
          'speed': 0.0,
          'heading': 0.0,
        };
        _channel?.sink.add(jsonEncode(fakeData));
      }
    } catch (e) {
      debugPrint('❌ Failed to connect to tracking WebSocket: $e');
      return;
    }

    // 3. Start streaming GPS (high accuracy, no distance filter for constant sync)
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            if (!_isTracking) return;
            final locationData = {
              'event': 'LOCATION_UPDATE',
              'lat': position.latitude,
              'lng': position.longitude,
              'speed': position.speed,
              'heading': position.heading,
            };

            _channel?.sink.add(jsonEncode(locationData));
            debugPrint(
              '📍 GPS stream → server: ${position.latitude.toStringAsFixed(5)}, '
              '${position.longitude.toStringAsFixed(5)}',
            );
          },
          onError: (error) {
            debugPrint('❌ GPS stream error: $error');
          },
        );
  }

  /// Stop GPS tracking and close the WebSocket.
  /// Call this when the delivery is completed or cancelled.
  void stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    _channel?.sink.close();
    _channel = null;
    _isTracking = false;
    debugPrint('🛑 Live tracking stopped.');
  }
}
