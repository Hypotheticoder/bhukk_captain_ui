import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:bhukkdelivery/providers/delivery/driver_location_provider.dart';
import 'package:bhukkdelivery/providers/delivery/route_provider.dart';
import 'package:bhukkdelivery/services/map_service.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:bhukkdelivery/cards/live_navigation_screen/widgets/geo_math.dart';
import 'package:bhukkdelivery/cards/live_navigation_screen/widgets/route_polyline_builder.dart';
import 'package:bhukkdelivery/cards/live_navigation_screen/widgets/route_trimmer.dart';
import 'package:bhukkdelivery/cards/live_navigation_screen/widgets/turn_by_turn_engine.dart';
import 'package:bhukkdelivery/cards/live_navigation_screen/widgets/fullscreen_map_overlay.dart';
import 'package:bhukkdelivery/cards/live_navigation_screen/widgets/compact_map_overlay.dart';
import 'package:bhukkdelivery/cards/live_navigation_screen/widgets/navigation_arrow_painter.dart';
import 'package:bhukkdelivery/cards/live_navigation_screen/widgets/status_chip.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';

// ─────────────────────────────────────────────────────────────
//  MapHeroCard — Google Map with polyline route line
//  Uses driver's live GPS as the start and delivery destination
//  as the end. Google Maps handles the location dot natively.
// ─────────────────────────────────────────────────────────────

class MapHeroCard extends ConsumerStatefulWidget {
  final Animation<double> pulseAnim;
  final Animation<double> bikeProgress;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;

  const MapHeroCard({
    super.key,
    required this.pulseAnim,
    required this.bikeProgress,
    this.isFullscreen = false,
    required this.onToggleFullscreen,
  });

  @override
  ConsumerState<MapHeroCard> createState() => _MapHeroCardState();
}

class _MapHeroCardState extends ConsumerState<MapHeroCard> {
  // ── Map ─────────────────────────────────────────────────
  final Completer<GoogleMapController> _controllerCompleter = Completer();
  GoogleMapController? _mapController;
  LatLng? _lastDriverPos;
  String? _drawnRouteKey;
  bool _isCameraTracking = true;
  bool _initialFitDone = false;
  bool _isUserPanning = false; // true while user drags the map manually
  bool _isProgrammaticMove = false; // prevents onCameraMoveStarted from locking the tracking

  // ── Polylines ──────────────────────────────────────────
  Set<Polyline> _polylines = {};

  // ── Cached driver state (via ref.listen, not ref.watch) ─
  double _lastSpeed = 0;
  double _lastHeading = 0;

  // ── Route geometry ─────────────────────────────────────
  List<LatLng> _routeGeometry = [];

  // ── Phase tracking ─────────────────────────────────────
  LatLng? _phaseStartPos;
  bool _lastIsPickupPhase = true;
  LatLng? _currentDestination;
  bool _usingBackendRoute = false;

  // ── Cached route async ─────────────────────────────────
  bool _routeLoading = true;

  // ── Extracted helpers ──────────────────────────────────
  final RouteTrimmer _trimmer = RouteTrimmer();
  final TurnByTurnEngine _navEngine = TurnByTurnEngine();

  // ── Custom navigation arrow ────────────────────────────
  BitmapDescriptor? _navArrowIcon;

  // ── Navigation camera constants ────────────────────────
  static const _navZoom = 18.5;
  static const _navTilt = 60.0;
  static const _compactZoom = 13.0;

  // ── 3D Premium Clear Map Skin ──────────────────────────
  static const String _mapStyleJson = '''
  [
    {
      "featureType": "poi",
      "elementType": "labels",
      "stylers": [
        { "visibility": "off" }
      ]
    },
    {
      "featureType": "transit",
      "elementType": "labels",
      "stylers": [
        { "visibility": "off" }
      ]
    }
  ]
  ''';

  // ────────────────────── Lifecycle ──────────────────────

  @override
  void initState() {
    super.initState();
    _navEngine.init();
    _createNavArrowIcon();
  }

  Future<void> _createNavArrowIcon() async {
    final icon = await NavigationArrowPainter.create();
    if (mounted) setState(() => _navArrowIcon = icon);
  }

  @override
  void dispose() {
    _navEngine.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // ────────────────────── Map callbacks ──────────────────

  void _onMapCreated(GoogleMapController controller) {
    if (!_controllerCompleter.isCompleted) {
      _controllerCompleter.complete(controller);
    }
    _mapController = controller;

    if (_routeGeometry.length >= 2) {
      _updatePolylines(_routeGeometry, _lastIsPickupPhase);
    }
  }

  @override
  void didUpdateWidget(MapHeroCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFullscreen == oldWidget.isFullscreen) return;

    if (widget.isFullscreen) {
      _isCameraTracking = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_lastDriverPos != null) {
          _recenterCamera();
        } else if (_routeGeometry.isNotEmpty) {
          _fitCameraToRoute(_routeGeometry);
        }
      });
    } else {
      _isCameraTracking = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_lastDriverPos != null && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: _lastDriverPos!,
                zoom: _compactZoom,
                tilt: 0,
                bearing: 0,
              ),
            ),
          );
        } else if (_routeGeometry.isNotEmpty) {
          _fitCameraToRoute(_routeGeometry);
        }
      });
    }
  }

  // ────────────────────── Route drawing ──────────────────

  void _updatePolylines(
    List<LatLng> points,
    bool isPickup, {
    String? key,
    bool force = false,
  }) {
    if (points.length < 2) return;
    if (!force && key != null && _drawnRouteKey == key) return;

    debugPrint(
      '🗺️ [Map] Drawing polyline: ${points.length} points '
      '(isPickup=$isPickup, force=$force)',
    );

    if (key != null && !force) _drawnRouteKey = key;

    setState(() {
      _polylines = RoutePolylineBuilder.build(points, isPickup: isPickup);
    });

    if (!_initialFitDone) {
      _initialFitDone = true;
      _fitCameraToRoute(points);
    }
  }

  // ────────────────────── Camera helpers ─────────────────

  Future<void> _fitCameraToRoute(List<LatLng> pts) async {
    if (_mapController == null || pts.length < 2) return;
    final bounds = MapService.instance.boundsForRoute(pts);
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
  }

  void _recenterCamera() {
    _isCameraTracking = true;
    _isUserPanning = false;
    final target = _lastDriverPos;
    if (target != null && _mapController != null) {
      _isProgrammaticMove = true;
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: target,
            zoom: _speedAdaptiveZoom(),
            tilt: _navTilt,
            bearing: _lastHeading,
          ),
        ),
      ).then((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _isProgrammaticMove = false;
        });
      });
    }
  }

  /// Zoom out slightly at higher speeds for better road visibility.
  double _speedAdaptiveZoom() {
    final kmh = _lastSpeed * 3.6;
    if (kmh > 80) return _navZoom - 1.5; // highway
    if (kmh > 50) return _navZoom - 0.8; // fast road
    if (kmh > 30) return _navZoom - 0.3; // city
    return _navZoom; // slow / stationary
  }

  // ────────────────────── Driver movement ────────────────

  void _onDriverMoved(LatLng pos, {double heading = 0}) {
    _lastDriverPos = pos;
    _lastHeading = heading;

    // 1. Camera tracking (skip if user is panning)
    if (widget.isFullscreen &&
        _isCameraTracking &&
        !_isUserPanning &&
        _mapController != null) {
      _isProgrammaticMove = true;
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: pos,
            zoom: _speedAdaptiveZoom(),
            tilt: _navTilt,
            bearing: heading,
          ),
        ),
      ).then((_) {
        // Unlock after completion
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _isProgrammaticMove = false;
        });
      });
    }

    // Update the driver arrow marker position
    if (widget.isFullscreen) {
      setState(() {}); // triggers marker rebuild in build()
    }

    // 2. Navigation engine (step advancement + off-route)
    final action = _navEngine.processDriverMove(
      pos,
      _routeGeometry,
      _usingBackendRoute,
    );

    switch (action) {
      case NavigationAction.stepAdvanced:
        if (mounted) setState(() {});
        _trimRouteLocally(pos);
        break;
      case NavigationAction.reroute:
        _reroute();
        break;
      case NavigationAction.trimOnly:
      case NavigationAction.none:
        _trimRouteLocally(pos);
        break;
    }
  }

  void _trimRouteLocally(LatLng pos) {
    final trimmed = _trimmer.trim(pos, _routeGeometry);
    if (trimmed != null) {
      _updatePolylines(trimmed, _lastIsPickupPhase,
          key: _drawnRouteKey, force: true);
    }
  }

  // ────────────────────── Rerouting ──────────────────────

  Future<void> _reroute() async {
    if (!_navEngine.canReroute) return;
    final driverPos = _lastDriverPos;
    final dest = _currentDestination;
    if (driverPos == null || dest == null) return;

    _navEngine.markRerouteStarted();
    debugPrint('[Reroute] Fetching new route from driver pos…');

    try {
      final result = await MapService.instance.fetchRoute(
        start: driverPos,
        end: dest,
      );

      if (!mounted || result.geometry.length < 2) return;

      _routeGeometry = result.geometry;
      _navEngine.resetForNewRoute(result.steps);
      _phaseStartPos = driverPos;
      _trimmer.reset();
      _drawnRouteKey = null;
      _initialFitDone = false;

      _updatePolylines(
        result.geometry,
        _lastIsPickupPhase,
        key: routeKey(driverPos, dest),
      );

      debugPrint(
          '[Reroute] New route drawn (${result.geometry.length} pts)');
      _navEngine.speak('Route recalculated.');

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('[Reroute] Failed: $e');
    } finally {
      _navEngine.markRerouteFinished();
    }
  }

  // ─────────────────────── TTS toggle callbacks ──────────

  void _handleTtsToggle() {
    setState(() => _navEngine.toggleTts());
  }

  void _handleTtsToggleWithResume() {
    setState(() {
      _navEngine.toggleTts();
      if (_navEngine.ttsEnabled) {
        final step = _navEngine.currentStep;
        if (step != null) {
          _navEngine.speak(step.instruction);
        }
      }
    });
  }

  // ─────────────────────────── Build ─────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    final delivery = ref.watch(activeDeliveryProvider);
    
    // Bootstrap initial location if listen hasn't fired yet
    if (_lastDriverPos == null) {
      final initialLoc = ref.read(driverLocationProvider);
      if (initialLoc != null) {
        _lastDriverPos = initialLoc.position;
        _lastSpeed = initialLoc.speed;
        _lastHeading = initialLoc.heading;
      }
    }
    final driverPos = _lastDriverPos;

    if (delivery == null) return const SizedBox.shrink();

    // ── Destination from delivery model ──────────────────
    final storePos = LatLng(
      delivery.pickupLocation.latitude,
      delivery.pickupLocation.longitude,
    );
    final customerPos = LatLng(
      delivery.dropoffLocation.latitude,
      delivery.dropoffLocation.longitude,
    );
    final destination = delivery.isPickupPhase ? storePos : customerPos;
    _currentDestination = destination;
    _usingBackendRoute = false;

    // ── Phase change detection ───────────────────────────
    if (_phaseStartPos == null ||
        _lastIsPickupPhase != delivery.isPickupPhase) {
      if (driverPos != null) {
        _phaseStartPos = driverPos;
        _lastIsPickupPhase = delivery.isPickupPhase;
        _initialFitDone = false;
        _drawnRouteKey = null;
        _trimmer.reset();
      }
    }

    final routeStart = _phaseStartPos ??
        LatLng(
          destination.latitude - 0.005,
          destination.longitude - 0.005,
        );

    final drawKey = routeKey(routeStart, destination);
    _usingBackendRoute = false;

    // ── Watch + listen route provider ────────────────────
    final routeAsync = ref.watch(routeProvider(drawKey));
    _routeLoading = routeAsync.isLoading;

    // Cache steps + geometry from latest result
    if (routeAsync.hasValue && routeAsync.value!.isNotEmpty) {
      final result = routeAsync.value!;
      if (_navEngine.steps.isEmpty ||
          _navEngine.steps.length != result.steps.length) {
        _navEngine.resetForNewRoute(result.steps);
      }
      _routeGeometry = result.geometry;

      // Ensure we draw the route if it was cached and the listener didn't fire
      if (_drawnRouteKey != drawKey) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updatePolylines(
              result.geometry,
              delivery.isPickupPhase,
              key: drawKey,
            );
          }
        });
      }
    }

    // Listen for driver location changes
    ref.listen<DriverLocation?>(driverLocationProvider, (previous, next) {
      if (next == null) return;
      _lastSpeed = next.speed;
      _lastHeading = next.heading;
      if (next.position != _lastDriverPos) {
        _onDriverMoved(next.position, heading: next.heading);
      }
    });

    // Listen for route updates (draw polyline when ready)
    ref.listen<AsyncValue<RouteResult>>(
      routeProvider(drawKey),
      (previous, next) {
        if (next.hasValue && next.value!.isNotEmpty) {
          debugPrint(
            '📍 [Route Listener] ✅ Got route: '
            '${next.value!.geometry.length} points',
          );
          _routeGeometry = next.value!.geometry;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updatePolylines(
              next.value!.geometry,
              delivery.isPickupPhase,
              key: drawKey,
            );
          });
        } else if (next.hasError) {
          debugPrint('📍 [Route Listener] ❌ Error: ${next.error}');
        }
      },
    );

    // ── Markers ──────────────────────────────────────────
    final currentMarkers = <Marker>{
      Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          delivery.isPickupPhase
              ? BitmapDescriptor.hueOrange
              : BitmapDescriptor.hueRed,
        ),
        infoWindow: InfoWindow(
          title: delivery.isPickupPhase ? 'Pickup' : 'Drop-off',
        ),
      ),
    };

    // ── Custom navigation arrow (fullscreen only) ────────
    if (widget.isFullscreen && driverPos != null && _navArrowIcon != null) {
      currentMarkers.add(Marker(
        markerId: const MarkerId('driver-arrow'),
        position: driverPos,
        icon: _navArrowIcon!,
        rotation: _lastHeading,
        anchor: const Offset(0.5, 0.5),
        flat: true, // lies flat on the map surface
      ));
    }

    // ── Turn-by-turn info ────────────────────────────────
    final currentStep = _navEngine.currentStep;
    double distToTurn = 0;
    if (currentStep != null && driverPos != null) {
      distToTurn = GeoMath.haversine(driverPos, currentStep.maneuverLocation);
      if (_routeGeometry.length >= 2) {
        final snap = GeoMath.distToPolyline(driverPos, _routeGeometry);
        if (snap < 30) {
          final along = (GeoMath.remainingDist(driverPos, _routeGeometry) -
                  GeoMath.remainingDist(
                    currentStep.maneuverLocation,
                    _routeGeometry,
                  ))
              .abs();
          if (along > 0) distToTurn = along;
        }
      }
    }

    final speedKmh = (_lastSpeed * 3.6).clamp(0.0, 999.0).roundToDouble();
    final isFs = widget.isFullscreen;
    final initialTarget = driverPos ?? destination;

    // ─────────────────────── Widget tree ─────────────────
    return Container(
      height: isFs ? double.infinity : 300,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.isDark
            ? const Color(0xFF1A1A24)
            : const Color(0xFFF0EDE6),
        borderRadius: isFs
            ? null
            : const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
        boxShadow: isFs
            ? null
            : [
                BoxShadow(
                  color: colors.cardShadow(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Stack(
        children: [
          // ── Google Map ─────────────────────────────────
          Animarker(
            curve: Curves.ease,
            useRotation: false, // Let the flutter_compass Gyro drive the rotation instead
            mapId: _controllerCompleter.future.then<int>((value) => value.mapId),
            markers: currentMarkers,
            child: GoogleMap(
              style: _mapStyleJson,
              initialCameraPosition: CameraPosition(
                target: initialTarget,
                zoom: isFs ? _navZoom : 12.5,
                tilt: isFs ? _navTilt : 0,
                bearing: isFs ? _lastHeading : 0,
              ),
              onMapCreated: _onMapCreated,
              polylines: _polylines,
              markers: <Marker>{}, // Handled automatically by Automarker physics engine
              myLocationEnabled: !isFs,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              // Detect manual user pan → disable auto-tracking
              onCameraMoveStarted: () {
                if (isFs && _isCameraTracking && !_isProgrammaticMove) {
                  _isUserPanning = true;
                  setState(() => _isCameraTracking = false);
                }
              },
              onCameraIdle: () {
                _isUserPanning = false;
              },
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 60,
                bottom: isFs ? 160 : 20,
              ),
            ),
          ),

          // ── Fullscreen overlays ────────────────────────
          if (isFs)
            Positioned.fill(
              child: FullscreenMapOverlay(
                currentStep: currentStep,
                distToTurn: distToTurn,
                speedKmh: speedKmh,
                ttsEnabled: _navEngine.ttsEnabled,
                onToggleTts: _handleTtsToggle,
                onToggleTtsResume: _handleTtsToggleWithResume,
                onBack: widget.onToggleFullscreen,
                onRecenter: _recenterCamera,
                delivery: delivery,
                routeAsync: routeAsync,
              ),
            ),

          // ── Compact overlays ───────────────────────────
          if (!isFs)
            Positioned.fill(
              child: CompactMapOverlay(
                pulseAnim: widget.pulseAnim,
                delivery: delivery,
                routeAsync: routeAsync,
                onToggleFullscreen: widget.onToggleFullscreen,
              ),
            ),

          // ── Loading / GPS status ───────────────────────
          if (_routeLoading)
            Positioned(
              bottom: isFs ? 170 : 16,
              left: isFs ? 70 : 16,
              child: const StatusChip(isLoading: true),
            ),
          if (!_routeLoading && driverPos == null)
            Positioned(
              bottom: isFs ? 170 : 16,
              left: isFs ? 70 : 16,
              child: const StatusChip(isLoading: false),
            ),
        ],
      ),
    );
  }
}
