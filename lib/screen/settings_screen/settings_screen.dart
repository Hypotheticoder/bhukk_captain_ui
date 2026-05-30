import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          "Settings",
          style: AppTextStyles.headingSm.copyWith(color: colors.textPrimary),
        ),
        backgroundColor: colors.surface,
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      body: Center(
        child: Text(
          "Settings Page (Coming Soon)",
          style: AppTextStyles.bodyLg.copyWith(color: colors.textSecondary),
        ),
      ),
    );
  }
}
