import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Splash brand widget — shows the Caby24 brand image
/// with a soft glow effect behind it.
class SplashLogo extends StatelessWidget {
  final double logoSize;

  const SplashLogo({super.key, this.logoSize = 120});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: logoSize * 2.8,
      height: logoSize,
      decoration: BoxDecoration(
        borderRadius: AppRadius.xlAll,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(30),
            blurRadius: 60,
            spreadRadius: 20,
          ),
          BoxShadow(
            color: AppColors.darkCyan.withAlpha(50),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Image.asset(
        'assets/icons/brand.png',
        height: logoSize,
        fit: BoxFit.contain,
      ),
    );
  }
}
