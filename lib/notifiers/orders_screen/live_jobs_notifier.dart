import 'dart:async';

import 'package:bhukkdelivery/models/dispatch_job.dart';
import 'package:bhukkdelivery/notifiers/home_screen/master_dashboard_notifier.dart';
import 'package:bhukkdelivery/notifiers/orders_screen/orders_notifier.dart';
import 'package:bhukkdelivery/providers/home/master_dashboard_provider.dart';
import 'package:bhukkdelivery/services/api/dispatch_job_service.dart';
import 'package:bhukkdelivery/services/location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

// ── State ─────────────────────────────────────────────
class LiveJobsState {
  final List<OrderItem> liveJobs;
  final bool isConnected;
  final bool isLoading;
  final String? error;

  const LiveJobsState({
    this.liveJobs = const [],
    this.isConnected = false,
    this.isLoading = false,
    this.error,
  });

  LiveJobsState copyWith({
    List<OrderItem>? liveJobs,
    bool? isConnected,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return LiveJobsState(
      liveJobs: liveJobs ?? this.liveJobs,
      isConnected: isConnected ?? this.isConnected,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Maps MasterDashboard serviceId → backend type_filter value.
String? _serviceIdToTypeFilter(String serviceId) {
  switch (serviceId) {
    case 'parcel':
      return 'parcel';
    case 'car_booking':
      return 'ride';
    case 'food_delivery':
      return 'food';
    case 'ambulance':
      return 'ambulance';
    case 'heavy_delivery':
      return 'heavy';
    case 'cosmatics':
      return 'cosmatics';
    case 'beverages':
      return 'beverages';
    default:
      return serviceId;
  }
}

// ── Notifier ──────────────────────────────────────────
class LiveJobsNotifier extends Notifier<LiveJobsState> {
  final _service = DispatchJobService.instance;
  StreamSubscription<DispatchJob>? _wsSub;
  Timer? _pollingTimer;
  Position? _driverPosition;
  List<String> _activeServiceIds = [];

  @override
  LiveJobsState build() {
    // Listen for service toggle changes from the master dashboard.
    ref.listen(masterDashboardProvider, (prev, next) {
      _onServiceToggleChanged(next);
    });

    // Clean up on dispose.
    ref.onDispose(() {
      _wsSub?.cancel();
      _pollingTimer?.cancel();
      _service.disconnect();
    });

    return const LiveJobsState();
  }

  /// Called when the master dashboard toggles change.
  void _onServiceToggleChanged(MasterDashboardState dashState) {
    final enabledServices = dashState.services
        .where((s) => s.isOnline)
        .map((s) => s.serviceId)
        .toList();

    if (enabledServices.isEmpty) {
      // All services offline — disconnect and clear.
      _wsSub?.cancel();
      _pollingTimer?.cancel();
      _service.disconnect();
      _activeServiceIds = [];
      state = const LiveJobsState();
      return;
    }

    _activeServiceIds = enabledServices;
    _connectAndFetch(enabledServices);
    
    // Start polling since global dispatch WebSocket is not actively supported by the backend wrapper
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_activeServiceIds.isNotEmpty) {
        _connectAndFetch(_activeServiceIds, isPolling: true);
      }
    });
  }

  /// Connect WebSocket and fetch initial jobs for enabled services.
  Future<void> _connectAndFetch(List<String> serviceIds, {bool isPolling = false}) async {
    if (!isPolling) {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    // Get the driver's current position for distance sorting.
    try {
      _driverPosition = await LocationService.instance.getCurrentPosition();
    } catch (_) {
      // Location unavailable — proceed without sorting.
    }

    // Fetch jobs for EACH enabled service type via HTTP.
    final allJobs = <OrderItem>[];

    for (final serviceId in serviceIds) {
      final typeFilter = _serviceIdToTypeFilter(serviceId);
      try {
        final jobs = await _service.listJobs(typeFilter: typeFilter);
        final actionableJobs = jobs.where((j) {
          final s = j.status.toUpperCase();
          return s == 'PENDING' || s == 'AVAILABLE' || s == 'SEARCHING';
        }).toList();
        allJobs.addAll(actionableJobs.map((j) => j.toOrderItem()));
      } catch (_) {
        // Continue with other services even if one fails.
      }
    }

    _sortByDistance(allJobs);

    state = state.copyWith(
      liveJobs: allJobs,
      isLoading: false,
      isConnected: true,
    );

    // Connect WebSocket for real-time updates (no filter — we filter client-side).
    _wsSub?.cancel();
    await _service.connect();

    _wsSub = _service.jobStream.listen((job) {
      _onNewJobReceived(job);
    });

    state = state.copyWith(isConnected: _service.isConnected);
  }

  /// Handle a new job arriving via WebSocket.
  void _onNewJobReceived(DispatchJob job) {
    // Filter: only accept jobs matching enabled services.
    final jobType = job.orderType.toLowerCase();
    final isAllowed = _activeServiceIds.any((serviceId) {
      final filter = _serviceIdToTypeFilter(serviceId)?.toLowerCase();
      return filter == jobType;
    });
    if (!isAllowed) return;

    final s = job.status.toUpperCase();
    final isActionable = s == 'PENDING' || s == 'AVAILABLE' || s == 'SEARCHING';

    if (!isActionable) {
      final updatedJobs = state.liveJobs.where((j) => j.id != job.id).toList();
      state = state.copyWith(liveJobs: updatedJobs, isConnected: true);
      return;
    }

    final orderItem = job.toOrderItem();

    // De-duplicate by ID.
    final updatedJobs = List<OrderItem>.from(state.liveJobs);
    final existingIndex = updatedJobs.indexWhere((o) => o.id == orderItem.id);
    if (existingIndex != -1) {
      updatedJobs[existingIndex] = orderItem;
    } else {
      updatedJobs.insert(0, orderItem); // New jobs at the top.
    }

    _sortByDistance(updatedJobs);
    state = state.copyWith(liveJobs: updatedJobs, isConnected: true);
  }

  /// Sort jobs by distance (shortest first).
  void _sortByDistance(List<OrderItem> jobs) {
    if (_driverPosition == null) return;
    jobs.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
  }

  /// Manually refresh the job list.
  Future<void> refresh() async {
    if (_activeServiceIds.isEmpty) return;
    await _connectAndFetch(_activeServiceIds);
  }

  /// Accept a job by its ID.
  Future<bool> acceptJob(String jobId, {required String driverId}) async {
    final result = await _service.acceptJob(jobId, driverId: driverId);
    if (result != null) {
      // Remove from live list after acceptance.
      final updatedJobs =
          state.liveJobs.where((j) => j.id != jobId).toList();
      state = state.copyWith(liveJobs: updatedJobs);
      return true;
    }
    return false;
  }
}
