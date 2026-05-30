import 'package:bhukkdelivery/providers/help_support/help_support_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuickHelpTopicsCard extends ConsumerWidget {
  const QuickHelpTopicsCard({super.key});

  static const Map<String, IconData> _categoryIcons = {
    'All': Icons.grid_view_rounded,
    'Payments': Icons.account_balance_wallet_rounded,
    'Orders': Icons.receipt_long_rounded,
    'Account': Icons.person_outline_rounded,
    'Navigation': Icons.map_outlined,
    'Safety': Icons.shield_outlined,
  };

  static const Map<String, Color> _categoryColors = {
    'All': AppColors.primary,
    'Payments': AppColors.success,
    'Orders': AppColors.warning,
    'Account': AppColors.info,
    'Navigation': AppColors.purple,
    'Safety': AppColors.error,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = C.of(context);
    final selectedIndex = ref.watch(
      helpSupportProvider.select((s) => s.selectedCategoryIndex),
    );

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: helpCategories.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = helpCategories[index];
          final isSelected = index == selectedIndex;
          final color = _categoryColors[category] ?? AppColors.primary;
          final icon = _categoryIcons[category] ?? Icons.help_outline;

          return GestureDetector(
            onTap: () {
              ref.read(helpSupportProvider.notifier).selectCategory(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withAlpha(colors.isDark ? 45 : 20)
                    : colors.surfaceElevated,
                borderRadius: AppRadius.pillAll,
                border: Border.all(
                  color: isSelected
                      ? color.withAlpha(colors.isDark ? 80 : 50)
                      : colors.blush.withAlpha(colors.isDark ? 40 : 100),
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withAlpha(colors.isDark ? 30 : 20),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected ? color : colors.textTertiary,
                  ),
                  const SizedBox(width: AppSpacing.xs + 2),
                  Text(
                    category,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? color : colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
