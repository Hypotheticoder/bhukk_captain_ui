import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FoodDeliveryActionsCard extends StatelessWidget {
  const FoodDeliveryActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return Column(
      children: [
        // ── Prominent "Take Food Orders" CTA ──
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
            );
          },
          child: GestureDetector(
            onTap: () {
              context.push('/home/food_delivery/take_orders');
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg + 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.foodDelivery,
                    AppColors.foodDelivery.withAlpha(200),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: AppRadius.xlAll,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.foodDelivery.withAlpha(90),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.restaurant_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    "Take Food Orders",
                    style: AppTextStyles.buttonText.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Secondary quick actions ──
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _secondaryActions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 0.92,
          ),
          itemBuilder: (context, index) {
            final action = _secondaryActions[index];

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 700 + index * 100),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
                );
              },
              child: InkWell(
                onTap: () {
                  if (action.route != null) {
                    context.push(action.route!);
                  } else {
                    context.push('/home/food_delivery/take_orders');
                  }
                },
                borderRadius: AppRadius.xlAll,
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
                          color: action.color.withAlpha(
                            colors.isDark ? 35 : 20,
                          ),
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
        ),
      ],
    );
  }

  static const _secondaryActions = <_ActionItem>[
    _ActionItem(
      icon: Icons.history_rounded,
      label: "Order\nHistory",
      color: AppColors.foodDelivery,
      route: '/home/food_delivery/history',
    ),
    _ActionItem(
      icon: Icons.account_balance_wallet_rounded,
      label: "My\nEarnings",
      color: AppColors.success,
      route: '/home/food_delivery/earnings',
    ),
    _ActionItem(
      icon: Icons.headset_mic_outlined,
      label: "Help &\nSupport",
      color: AppColors.info,
      route: '/home/help_support',
    ),
  ];
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
