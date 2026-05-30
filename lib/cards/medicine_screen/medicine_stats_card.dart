import 'package:bhukkdelivery/providers/medicine/medicine_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MedicineStatsCard extends ConsumerWidget {
  const MedicineStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = C.of(context);
    final state = ref.watch(medicineProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: colors.accentBorderedCard.copyWith(
        border: Border.all(
          color: AppColors.medicine.withAlpha(colors.isDark ? 50 : 45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.medicine.withAlpha(colors.isDark ? 20 : 25),
            blurRadius: 25,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStat(
            icon: Icons.medical_services_rounded,
            value: state.totalMedicines.toString(),
            label: "Total",
            color: AppColors.medicine,
            colors: colors,
          ),
          _buildDivider(colors),
          _buildStat(
            icon: Icons.check_circle_outline_rounded,
            value: "${state.deliveryRate.toStringAsFixed(0)}%",
            label: "Delivered",
            color: AppColors.success,
            colors: colors,
          ),
          _buildDivider(colors),
          _buildStat(
            icon: Icons.scale_rounded,
            value: "${state.avgWeight.toStringAsFixed(1)}kg",
            label: "Avg. Wt",
            color: AppColors.info,
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required C colors,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withAlpha(colors.isDark ? 35 : 18),
              borderRadius: AppRadius.smAll,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.statValue.copyWith(
              color: colors.textPrimary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: colors.textTertiary,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(C colors) {
    return Container(
      width: 1,
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      color: colors.divider,
    );
  }
}
