import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BeveragesActionsCard extends StatelessWidget {
  const BeveragesActionsCard({super.key});

  static const _actions = <_ActionItem>[
    _ActionItem(
      icon: Icons.delivery_dining_rounded,
      label: "Take\nOrders",
      color: AppColors.beverages,
      route: null,
    ),
    _ActionItem(
      icon: Icons.history_rounded,
      label: "Order\nHistory",
      color: AppColors.warning,
      route: 'history',
    ),
    _ActionItem(
      icon: Icons.account_balance_wallet_rounded,
      label: "My\nEarnings",
      color: AppColors.success,
      route: 'earnings',
    ),
    _ActionItem(
      icon: Icons.headset_mic_outlined,
      label: "Help &\nSupport",
      color: AppColors.info,
      route: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) {
        final action = _actions[index];

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
            onTap: action.route != null
                ? () => context.push('/home/beverages/${action.route}')
                : null,
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
  final String? route;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    this.route,
  });
}
