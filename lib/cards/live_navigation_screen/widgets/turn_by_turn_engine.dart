import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bhukkdelivery/services/map_service.dart';
import 'geo_math.dart';

/// The result of processing a driver GPS fix.
enum NavigationAction {
  /// Nothing happened — no UI update needed.
  none,

  /// A turn-by-turn step was advanced and spoken. Caller should setState.
  stepAdvanced,

  /// The driver is > 50 m off-route. Caller should trigger a reroute.
  reroute,

  /// Just trim the existing polyline locally. No network call needed.
  trimOnly,
}

/// Self-contained turn-by-turn + off-route detection engine.
///
/// Manages TTS, step tracking, and distance-based throttling.
/// Returns a [NavigationAction] so the caller knows what to do
/// without this class needing references to the map controller.
class TurnByTurnEngine {
  final FlutterTts _tts = FlutterTts();
  bool ttsEnabled = true;
  int _lastSpokenStepIndex = -1;

  /// Current sequence of manoeuvre steps from the route.
  List<RouteStep> steps = [];

  /// Index into [steps] the driver is approaching.
  int currentStepIndex = 0;

  // ── Off-route state ────────────────────────────────────
  bool isRerouting = false;
  DateTime? _lastRerouteTime;

  /// Last position at which a network route was fetched.
  LatLng? lastRouteFetchPos;

  /// Initialise the TTS engine.
  Future<void> init() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  /// Speak [text] if TTS is enabled.
  void speak(String text) {
    if (!ttsEnabled) return;
    _tts.speak(text);
  }

  void stopSpeaking() => _tts.stop();

  /// Toggle TTS on/off. Stops playback when disabling.
  void toggleTts() {
    ttsEnabled = !ttsEnabled;
    if (!ttsEnabled) _tts.stop();
  }

  /// The step the driver is currently approaching, or `null`.
  RouteStep? get currentStep =>
      (steps.isNotEmpty && currentStepIndex < steps.length)
          ? steps[currentStepIndex]
          : null;

  /// Replace the step list (e.g. after a reroute) and reset tracking.
  void resetForNewRoute(List<RouteStep> newSteps) {
    steps = newSteps;
    currentStepIndex = 0;
    _lastSpokenStepIndex = -1;
    lastRouteFetchPos = null;
  }

  /// Whether a reroute is allowed right now (5-second cooldown).
  bool get canReroute {
    if (isRerouting) return false;
    final now = DateTime.now();
    if (_lastRerouteTime != null &&
        now.difference(_lastRerouteTime!).inSeconds < 5) {
      return false;
    }
    return true;
  }

  void markRerouteStarted() {
    isRerouting = true;
    _lastRerouteTime = DateTime.now();
  }

  void markRerouteFinished() => isRerouting = false;

  /// Process a single GPS fix. Returns the action the caller should take.
  NavigationAction processDriverMove(
    LatLng pos,
    List<LatLng> routeGeometry,
    bool usingBackendRoute,
  ) {
    // 1. Turn-by-turn: advance step if driver is within 90 m
    if (steps.isNotEmpty && currentStepIndex < steps.length) {
      final step = steps[currentStepIndex];
      final dist = GeoMath.haversine(pos, step.maneuverLocation);
      if (dist < 90 && _lastSpokenStepIndex != currentStepIndex) {
        _lastSpokenStepIndex = currentStepIndex;
        speak(step.instruction);
        currentStepIndex++;
        return NavigationAction.stepAdvanced;
      }
    }

    // 2. Off-route detection (> 50 m from polyline)
    if (routeGeometry.isNotEmpty && !usingBackendRoute) {
      final offRoute = GeoMath.distToPolyline(pos, routeGeometry);
      if (offRoute > 50) {
        if (_lastSpokenStepIndex != -2) {
          _lastSpokenStepIndex = -2;
          speak('Recalculating route.');
        }
        lastRouteFetchPos = pos;
        return NavigationAction.reroute;
      }
    }

    // 3. Distance throttle: only re-fetch if moved ≥ 50 m
    if (lastRouteFetchPos != null) {
      final distMoved = GeoMath.haversine(pos, lastRouteFetchPos!);
      if (distMoved < 50) {
        return NavigationAction.trimOnly;
      }
    }

    lastRouteFetchPos = pos;
    return NavigationAction.trimOnly;
  }

  void dispose() => _tts.stop();
}
