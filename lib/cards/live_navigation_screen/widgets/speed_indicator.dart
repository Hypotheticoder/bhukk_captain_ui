import 'package:flutter/material.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';

class SpeedIndicator extends StatelessWidget {
  final double speedKmh;

  const SpeedIndicator({super.key, this.speedKmh = 0});

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    final speed = speedKmh.toInt();
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: colors.isDark
            ? Colors.black.withAlpha(180)
            : Colors.white.withAlpha(230),
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.isDark
              ? Colors.white.withAlpha(30)
              : Colors.black.withAlpha(15),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$speed',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          Text(
            'km/h',
            style: TextStyle(
              color: colors.textTertiary,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
