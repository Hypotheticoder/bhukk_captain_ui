import 'package:bhukkdelivery/providers/orders/orders_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderFilterChips extends ConsumerWidget {
  const OrderFilterChips({super.key});

  static const Map<int, IconData> _statusIcons = {
    0: Icons.grid_view_rounded,
    1: Icons.check_circle_outline_rounded,
    2: Icons.cancel_outlined,
    3: Icons.timelapse_rounded,
  };

  static const Map<int, Color> _statusColors = {
    0: AppColors.primary,
    1: AppColors.success,
    2: AppColors.error,
    3: AppColors.warning,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = C.of(context);
    final state = ref.watch(ordersProvider);
    final selectedStatus = state.selectedFilterIndex;
    final selectedService = state.selectedServiceIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Row 1: Service type filter ──
        Text(
          "SERVICE",
          style: AppTextStyles.overline.copyWith(
            color: colors.textTertiary,
            fontSize: 10,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: state.availableServiceFilters.length,
            separatorBuilder: (_, index) =>
                const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final isActive = index == selectedService;
              final label = state.availableServiceFilters[index];
              final svcKey = label.toLowerCase();
              final meta = serviceMetaMap[svcKey];
              final color = meta?.color ?? AppColors.primary;
              final icon = meta?.icon ?? Icons.grid_view_rounded;

              return GestureDetector(
                onTap: () => ref
                    .read(ordersProvider.notifier)
                    .selectServiceFilter(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md + 2,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? color : colors.surfaceElevated,
                    borderRadius: AppRadius.pillAll,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: color.withAlpha(80),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: colors.cardShadow(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        index == 0 ? Icons.apps_rounded : icon,
                        size: 14,
                        color: isActive ? Colors.white : colors.textTertiary,
                      ),
                      const SizedBox(width: AppSpacing.xs + 2),
                      Text(
                        label,
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Row 2: Status filter ──
        Text(
          "STATUS",
          style: AppTextStyles.overline.copyWith(
            color: colors.textTertiary,
            fontSize: 10,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: orderStatusLabels.length,
            separatorBuilder: (_, index) =>
                const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final isActive = index == selectedStatus;
              final color = _statusColors[index] ?? AppColors.primary;

              return GestureDetector(
                onTap: () =>
                    ref.read(ordersProvider.notifier).selectFilter(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? color : colors.surfaceElevated,
                    borderRadius: AppRadius.pillAll,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: color.withAlpha(80),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: colors.cardShadow(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _statusIcons[index],
                        size: 15,
                        color: isActive ? Colors.white : colors.textTertiary,
                      ),
                      const SizedBox(width: AppSpacing.xs + 2),
                      Text(
                        orderStatusLabels[index],
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
