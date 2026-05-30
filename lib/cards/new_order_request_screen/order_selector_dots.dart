import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';

class OrderSelectorDots extends StatelessWidget {
  final int count;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const OrderSelectorDots({
    super.key,
    required this.count,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;

        return GestureDetector(
          onTap: () => onTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: isActive ? 28 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              borderRadius: AppRadius.pillAll,
              color: isActive
                  ? AppColors.primary
                  : colors.textTertiary.withAlpha(60),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(60),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}
