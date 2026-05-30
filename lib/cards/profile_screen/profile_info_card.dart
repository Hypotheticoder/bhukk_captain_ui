import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ProfileInfoCard extends StatelessWidget {
  final List<ProfileInfoRow> rows;

  const ProfileInfoCard({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: colors.card,
      child: Column(
        children: rows
            .map((row) => _buildInfoRow(row.icon, row.label, row.value, colors))
            .toList(),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, C colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: colors.textTertiary),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: colors.textPrimary.withAlpha(222),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileInfoRow {
  final IconData icon;
  final String label;
  final String value;

  const ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
}
