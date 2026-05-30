import 'dart:async';
import 'dart:convert';

import 'package:bhukkdelivery/models/dispatch_job.dart';
import 'package:bhukkdelivery/services/api/api_config.dart';
import 'package:bhukkdelivery/services/location_service.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Service for dispatch-job operations (HTTP + WebSocket).
class DispatchJobService {
  static final Dio _dio = ApiConfig.dio;

  WebSocketChannel? _channel;
  StreamController<DispatchJob>? _jobStreamController;
  StreamController<Map<String, dynamic>>? _cancelStreamController;
  bool _isConnected = false;

  // ─── Singleton ──────────────────────────────────────
  DispatchJobService._();
  static final DispatchJobService instance = DispatchJobService._();

  /// Whether the WebSocket is currently connected.
  bool get isConnected => _isConnected;

  // ─── HTTP Methods ───────────────────────────────────

  List<dynamic> _extractListPayload(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      final items =
          data['items'] ?? data['data'] ?? data['jobs'] ?? data['results'];
      if (items is List) return items;
    }
    return const [];
  }

  /// Fetch list of pending dispatch jobs.
  /// GET /drivers/jobs/available?type_filter=parcel|ride&skip=0&limit=100
  Future<List<DispatchJob>> listJobs({
    String? typeFilter,
    double? driverLat,
    double? driverLng,
    bool? acceptsRides,
    bool? acceptsParcels,
    bool? acceptsMedicines,
    int skip = 0,
    int limit = 100,
  }) async {
    final queryParams = <String, dynamic>{'skip': skip, 'limit': limit};
    if (typeFilter != null && typeFilter.isNotEmpty) {
      queryParams['type_filter'] = typeFilter;
    }

    // Backend requires driver_lat/driver_lng — auto-fetch if not provided
    if (driverLat == null || driverLng == null) {
      try {
        final pos = await LocationService.instance.getCurrentPosition();
        if (pos != null) {
          driverLat ??= pos.latitude;
          driverLng ??= pos.longitude;
        }
      } catch (e) {
        debugPrint('[DispatchJobService] Failed to get location: $e');
      }
    }

    if (driverLat != null) queryParams['driver_lat'] = driverLat;
    if (driverLng != null) queryParams['driver_lng'] = driverLng;
    if (acceptsRides != null) queryParams['accepts_rides'] = acceptsRides;
    if (acceptsParcels != null) queryParams['accepts_parcels'] = acceptsParcels;
    if (acceptsMedicines != null) queryParams['accepts_medicines'] = acceptsMedicines;

    bool matchesTypeFilter(DispatchJob job, String filter) {
      final f = filter.trim().toLowerCase();
      final t = job.orderType.trim().toLowerCase();

      if (f.isEmpty) return true;

      if (f == 'ride') {
        return t == 'ride' ||
            t == 'car_booking' ||
            t == 'cab' ||
            t == 'car' ||
            t.contains('ride');
      }
      if (f == 'parcel') {
        return t == 'parcel' || t.contains('parcel') || t == 'medicine' || t == 'food' || t == 'grocery' || t == 'cosmetics' || t == 'pharmacy';
      }

      return t == f;
    }

    List<DispatchJob> applyClientFilter(List<DispatchJob> jobs) {
      if (typeFilter == null || typeFilter.trim().isEmpty) return jobs;
      return jobs.where((j) => matchesTypeFilter(j, typeFilter)).toList();
    }

    // Primary: driver-available jobs endpoint.
    try {
      final response = await _dio.get(
        '/drivers/jobs/available',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200 && response.data != null) {
        final items = _extractListPayload(response.data);
        if (items.isNotEmpty) {
          final jobs = items
              .map(
                (item) => DispatchJob.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();
          return applyClientFilter(jobs);
        }
      }
    } on DioException {
      // Ignore and fall back.
    }

    return [];
  }

  /// Get a single dispatch job by ID.
  /// GET /drivers/jobs/{order_id}
  Future<DispatchJob?> getJob(String jobId) async {
    // Primary.
    try {
      final response = await _dio.get('/drivers/jobs/$jobId');
      if (response.statusCode == 200 && response.data != null) {
        return DispatchJob.fromJson(Map<String, dynamic>.from(response.data));
      }
    } on DioException {
      // Ignore and fall back.
    }

    // Fallback.
    try {
      final fallback = await _dio.get('/customer_orders/$jobId');
      if (fallback.statusCode == 200 && fallback.data != null) {
        return DispatchJob.fromJson(Map<String, dynamic>.from(fallback.data));
      }
    } on DioException {
      // Ignore.
    }

    return null;
  }

  /// Accept a dispatch job.
  /// POST /drivers/jobs/{order_id}/accept
  Future<Map<String, dynamic>?> acceptJob(
    String jobId, {
    String? driverId,
  }) async {
    try {
      final qp = <String, dynamic>{};
      // Some backends derive driver from Firebase token; others expect driver_id.
      if (driverId != null &&
          driverId.isNotEmpty &&
          driverId != 'current_driver') {
        qp['driver_id'] = driverId;
      }
      final response = await _dio.post(
        '/drivers/jobs/$jobId/accept',
        queryParameters: qp.isEmpty ? null : qp,
      );
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } on DioException {
      return null;
    }
  }

  /// Update job status (OTP-gated on backend for some transitions).
  /// PUT /drivers/jobs/{order_id}/status
  Future<
    ({
      bool ok,
      int? statusCode,
      Map<String, dynamic>? data,
      String? errorMessage,
    })
  >
  updateJobStatus(
    String jobId, {
    required String newStatus,
    String? otp,
  }) async {
    try {
      // Backends are inconsistent here: some expect `new_status`, others `status`.
      // Send both to stay compatible.
      final payload = <String, dynamic>{
        'new_status': newStatus,
        'status': newStatus,
      };
      if (otp != null && otp.isNotEmpty) payload['otp'] = otp;
      final response = await _dio.put(
        '/drivers/jobs/$jobId/status',
        data: payload,
      );
      if (response.statusCode == 200 && response.data != null) {
        return (
          ok: true,
          statusCode: response.statusCode,
          data: Map<String, dynamic>.from(response.data),
          errorMessage: null,
        );
      }
      return (
        ok: false,
        statusCode: response.statusCode,
        data: null,
        errorMessage: 'Unexpected response',
      );
    } on DioException catch (e) {
      String? msg;
      final data = e.response?.data;

      String? formatValidationList(dynamic maybeList) {
        if (maybeList is! List) return null;
        if (maybeList.isEmpty) return null;

        // FastAPI/Pydantic commonly returns:
        // [{"loc": ["body", "status"], "msg": "Field required", "type": "missing"}, ...]
        final first = maybeList.first;
        if (first is Map) {
          final loc = first['loc'];
          final locText = loc is List ? loc.join('.') : null;
          final msgText = first['msg']?.toString();
          if (msgText != null && msgText.isNotEmpty) {
            return locText != null && locText.isNotEmpty
                ? '$msgText ($locText)'
                : msgText;
          }
        }

        // Fallback: stringify the whole list.
        return maybeList.toString();
      }

      if (data is Map) {
        // detail can be a string OR a list of validation errors.
        final detail = data['detail'];
        msg =
            formatValidationList(detail) ??
            detail?.toString() ??
            data['message']?.toString() ??
            data['error']?.toString();
      } else {
        msg = formatValidationList(data) ?? data?.toString();
      }

      msg ??= e.message;
      return (
        ok: false,
        statusCode: e.response?.statusCode,
        data: null,
        errorMessage: msg,
      );
    }
  }

  /// Confirm payment collection for a job.
  /// PUT /drivers/jobs/{order_id}/payment
  /// Marks the order as "paid" in the database.
  Future<({bool ok, String? errorMessage})> confirmPayment(
    String jobId, {
    required String method, // 'cash' or 'upi'
  }) async {
    try {
      final response = await _dio.put(
        '/drivers/jobs/$jobId/payment',
        data: {
          'payment_status': 'paid',
          'payment_method': method,
        },
      );
      if (response.statusCode == 200) {
        return (ok: true, errorMessage: null);
      }
      return (
        ok: false,
        errorMessage: response.data?['detail']?.toString() ?? 'Unexpected response',
      );
    } on DioException catch (e) {
      String? msg;
      final data = e.response?.data;
      if (data is Map) {
        msg = data['detail']?.toString() ??
            data['message']?.toString() ??
            data['error']?.toString();
      }
      msg ??= e.message;
      return (ok: false, errorMessage: msg);
    }
  }

  /// Cancel a dispatch job.
  /// POST /customer_orders/{order_id}/cancel
  Future<({bool ok, int? statusCode, String? errorMessage})> cancelOrder(
    String orderId, {
    String? driverId,
  }) async {
    try {
      final qp = <String, dynamic>{
        'user_type': 'driver',
      };
      if (driverId != null && driverId.isNotEmpty) {
        qp['user_id'] = driverId;
      }
      final response = await _dio.post(
        '/customer_orders/$orderId/cancel',
        queryParameters: qp,
      );
      if (response.statusCode == 200) {
        return (ok: true, statusCode: 200, errorMessage: null);
      }
      return (
        ok: false,
        statusCode: response.statusCode,
        errorMessage: 'Unexpected response',
      );
    } on DioException catch (e) {
      String? msg;
      final data = e.response?.data;
      if (data is Map) {
        msg = data['detail']?.toString() ??
            data['message']?.toString() ??
            data['error']?.toString();
      }
      msg ??= e.message;
      return (
        ok: false,
        statusCode: e.response?.statusCode,
        errorMessage: msg,
      );
    }
  }

  /// Reject/decline a dispatch job.
  /// There is no server-side "reject" endpoint in the current backend routes.
  /// In the app, "Reject" means: dismiss locally and continue listening.
  Future<bool> rejectJob(
    String jobId, {
    String? driverId,
    String? reason,
  }) async {
    return true;
  }

  // ─── WebSocket ──────────────────────────────────────

  /// Stream of incoming dispatch jobs via WebSocket.
  Stream<DispatchJob> get jobStream {
    _jobStreamController ??= StreamController<DispatchJob>.broadcast();
    return _jobStreamController!.stream;
  }

  /// Stream of cancellation events from the backend (e.g. CUSTOMER_CANCELLED).
  Stream<Map<String, dynamic>> get cancelStream {
    _cancelStreamController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _cancelStreamController!.stream;
  }

  /// Connect to the global driver WebSocket for incoming dispatch jobs.
  Future<void> connect({String? typeFilter}) async {
    // Disconnect any existing connection first.
    disconnect();

    _jobStreamController ??= StreamController<DispatchJob>.broadcast();
    _cancelStreamController ??= StreamController<Map<String, dynamic>>.broadcast();

    // Get Firebase auth token.
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken() ?? '';

    // Global driver channel (not order specific)
    final wsUrl = '${ApiConfig.wsBaseUrl}/drivers/ws?token=$token';

    try {
      debugPrint('🔌 Connecting to global driver WS: $wsUrl');
      final channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _channel = channel;
      _isConnected = true;

      channel.stream.listen(
        (message) {
          debugPrint('🔵 [Global WS] Message: $message');
          try {
            final data = jsonDecode(message.toString());
            final event = data['event'];

            if (event == 'NEW_JOB' && data['job'] is Map) {
              final job = DispatchJob.fromJson(
                Map<String, dynamic>.from(data['job']),
              );
              _jobStreamController?.add(job);
            } else if (event == 'CUSTOMER_CANCELLED' ||
                event == 'DRIVER_CANCELLED') {
              debugPrint('⚠️ Received $event via Global WS');
              _cancelStreamController?.add(data);
            }
          } catch (e) {
            debugPrint('⚠️ [Global WS] Parse Error: $e');
          }
        },
        onError: (err) {
          _isConnected = false;
          final errorStr = err.toString();
          debugPrint('🔴 [Global WS] Error: $errorStr');
          
          // If 403, don't retry immediately. It likely means we are restricted while on a job.
          if (errorStr.contains('403')) {
            debugPrint('🚫 [Global WS] 403 Forbidden. Stopping retries for now.');
            return;
          }

          // Attempt reconnect after a delay for other errors.
          Future.delayed(const Duration(seconds: 10), () {
            if (!_isConnected) {
              connect(typeFilter: typeFilter);
            }
          });
        },
        onDone: () {
          _isConnected = false;
          debugPrint('⚫ [Global WS] Connection closed.');
        },
        cancelOnError: true,
      );
    } catch (e) {
      _isConnected = false;
      debugPrint('🔴 [Global WS] Exception: $e');
    }
  }

  /// Disconnect the WebSocket.
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
  }

  /// Clean up resources.
  void dispose() {
    disconnect();
    _jobStreamController?.close();
    _jobStreamController = null;
    _cancelStreamController?.close();
    _cancelStreamController = null;
  }
}
