import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Draws a Google Maps-style navigation arrow (blue chevron with glow)
/// and converts it to a [BitmapDescriptor] for use as a map marker.
///
/// The arrow points UP — rotate it via [Marker.rotation] to match heading.
class NavigationArrowPainter {
  static BitmapDescriptor? _cachedIcon;

  /// Creates (and caches) the navigation arrow icon.
  /// [size] is in logical pixels — multiply by device pixel ratio
  /// for crisp rendering on high-DPI screens.
  static Future<BitmapDescriptor> create({double size = 140}) async {
    if (_cachedIcon != null) return _cachedIcon!;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final s = size;
    final cx = s / 2;
    final cy = s / 2;

    // ── 1. Outer pulsing glow ────────────────────────────
    final glowPaint = Paint()
      ..color = const Color(0x284285F4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(cx, cy), s * 0.48, glowPaint);

    // ── 2. Secondary glow ring ───────────────────────────
    final glow2 = Paint()
      ..color = const Color(0x1A4285F4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(cx, cy), s * 0.42, glow2);

    // ── 3. White border circle ───────────────────────────
    final borderPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), s * 0.36, borderPaint);

    // ── 4. Gradient blue fill ────────────────────────────
    final bluePaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(cx, cy - s * 0.05),
        s * 0.32,
        [const Color(0xFF5C9DF5), const Color(0xFF2D6FD6)],
        [0.0, 1.0],
      );
    canvas.drawCircle(Offset(cx, cy), s * 0.30, bluePaint);

    // ── 5. Navigation arrow (chevron pointing UP) ────────
    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final arrowH = s * 0.20; // arrow half-height
    final arrowW = s * 0.14; // arrow half-width
    final notchDepth = arrowH * 0.45;

    final path = Path()
      ..moveTo(cx, cy - arrowH) // tip (top)
      ..lineTo(cx + arrowW, cy + arrowH * 0.55) // bottom right
      ..lineTo(cx, cy + arrowH * 0.55 - notchDepth) // notch center
      ..lineTo(cx - arrowW, cy + arrowH * 0.55) // bottom left
      ..close();

    // Drop shadow under arrow for depth
    final shadowPaint = Paint()
      ..color = const Color(0x30000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.save();
    canvas.translate(0, 1.5);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // Actual arrow
    canvas.drawPath(path, arrowPaint);

    // ── 6. Tiny highlight dot at tip for polish ──────────
    final highlightPaint = Paint()
      ..color = Colors.white.withAlpha(120)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(cx, cy - arrowH + 4), 3, highlightPaint);

    // ── Convert to BitmapDescriptor ──────────────────────
    final picture = recorder.endRecording();
    final image = await picture.toImage(s.toInt(), s.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    _cachedIcon = BitmapDescriptor.bytes(
      byteData!.buffer.asUint8List(),
      bitmapScaling: MapBitmapScaling.none,
    );
    return _cachedIcon!;
  }

  /// Call this to invalidate the cached icon (e.g. on theme change).
  static void invalidateCache() => _cachedIcon = null;
}
