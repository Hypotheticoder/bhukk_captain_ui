import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class MapMarkerGenerator {
  /// Paint the driver marker: A clear directional navigation chevron (arrow).
  static Future<Uint8List> getDriverMarker() async {
    const double size = 120;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = const Offset(size / 2, size / 2);

    // Chevron shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(76)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = ui.Path();
    // A thick upward pointing chevron (sizes increased by ~1.5x)
    path.moveTo(center.dx, center.dy - 36); // Top point
    path.lineTo(center.dx - 27, center.dy + 30); // Bottom left
    path.lineTo(center.dx, center.dy + 12); // Inner notch
    path.lineTo(center.dx + 27, center.dy + 30); // Bottom right
    path.close();

    // Draw shadow slightly offset
    canvas.save();
    canvas.translate(0, 6);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // White border for visibility
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, borderPaint);

    // Blue core (Google Maps bright blue)
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, bluePaint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Paint a circular marker with an icon inside.
  static Future<Uint8List> getCircleMarker(Color color, IconData icon) async {
    const double size = 100;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(40)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(const Offset(size / 2, size / 2 + 3), 32, shadowPaint);

    // White outer ring
    final outerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(size / 2, size / 2), 32, outerPaint);

    // Colored inner circle
    final innerPaint = Paint()..color = color;
    canvas.drawCircle(const Offset(size / 2, size / 2), 26, innerPaint);

    // Icon using TextPainter with Material Icons font
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 28,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}
