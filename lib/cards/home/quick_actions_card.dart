import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:bhukkdelivery/providers/new_order/new_order_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class QuickActionsCard extends ConsumerWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = C.of(context);
    final activeDelivery = ref.watch(activeDeliveryProvider);

    final List<_ActionItem> actions = [
      if (activeDelivery != null)
        const _ActionItem(
          icon: Icons.near_me_rounded,
          label: "Track\nOrder",
          color: AppColors.warning,
        )
      else
        const _ActionItem(
          icon: Icons.delivery_dining_rounded,
          label: "Take\nOrders",
          color: AppColors.warning,
        ),
      const _ActionItem(
        icon: Icons.person_outline_rounded,
        label: "My\nProfile",
        color: AppColors.purple,
      ),
      const _ActionItem(
        icon: Icons.headset_mic_outlined,
        label: "Help &\nSupport",
        color: AppColors.success,
      ),
      // const _ActionItem(
      //   icon: Icons.fastfood_rounded,
      //   label: "Sell\nSnacks",
      //   color: AppColors.primary,
      // ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];

        VoidCallback? onTap;
        switch (index) {
          case 0:
            if (activeDelivery != null) {
              onTap = () => context.push('/home/live_navigation');
            } else {
              onTap = () {
                ref
                    .read(newOrderProvider.notifier)
                    .simulateMultipleServiceOrders(['parcel', 'car_booking']);
                context.push('/home/new_order');
              };
            }
            break;
          case 1:
            onTap = () => context.go('/profile');
            break;
          case 2:
            onTap = () => context.push('/home/help_support');
            break;
          // case 3:
          //   onTap = () => context.push('/home/snacks');
          //   break;
        }

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 600 + index * 100),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
            );
          },
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: AppRadius.lgAll,
                boxShadow: [
                  BoxShadow(
                    color: colors.cardShadow(0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm + 2),
                    decoration: BoxDecoration(
                      color: action.color.withAlpha(colors.isDark ? 35 : 20),
                      borderRadius: AppRadius.mdAll,
                    ),
                    child: Icon(action.icon, color: action.color, size: 22),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    action.label,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.textSecondary,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}
