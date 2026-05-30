import 'dart:async';
import 'package:bhukkdelivery/services/api/api_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Lightweight heartbeat service that periodically pings the backend.
///
/// If the driver has been banned by an admin, the 403 interceptor in
/// [ApiConfig] will automatically redirect them to the Suspended Screen.
/// This service ensures the driver gets kicked even if they're idle
/// on the map screen and not making any other API calls.
class BanCheckService {
  BanCheckService._();
  static final BanCheckService instance = BanCheckService._();

  Timer? _timer;
  bool _isRunning = false;

  /// How often to heartbeat (seconds).
  static const int _intervalSeconds = 30;

  /// Start the periodic ban check.
  /// Safe to call multiple times — will not double-start.
  void start() {
    if (_isRunning) return;
    _isRunning = true;

    debugPrint('[BanCheck] Started heartbeat (every ${_intervalSeconds}s)');

    // Immediate first check
    _ping();

    _timer = Timer.periodic(
      const Duration(seconds: _intervalSeconds),
      (_) => _ping(),
    );
  }

  /// Stop the periodic ban check.
  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    debugPrint('[BanCheck] Stopped heartbeat');
  }

  /// Single ping — hits a lightweight endpoint.
  /// The 403 interceptor in ApiConfig handles the rest.
  Future<void> _ping() async {
    try {
      await ApiConfig.dio.get(
        '/drivers/jobs/available',
        queryParameters: {
          'driver_lat': 0,
          'driver_lng': 0,
          'limit': 1,
        },
      );
    } on DioException catch (_) {
      // The _SuspensionInterceptor handles 403 globally.
      // All other errors are harmless pings — ignore them.
    }
  }
}
