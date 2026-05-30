import 'package:bhukkdelivery/notifiers/payment_screen/payment_notifier.dart';
import 'package:bhukkdelivery/providers/payment/payment_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Displays available payment methods as interactive tiles.
class PaymentMethodCard extends ConsumerWidget {
  const PaymentMethodCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentProvider);
    final colors = C.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Collect Payment",
          style: AppTextStyles.headingSm.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          "How does the customer want to pay?",
          style: AppTextStyles.caption.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ...state.availableMethods.map((method) {
          final isSelected = state.selectedMethod == method.type;
          return _MethodTile(
            method: method,
            isSelected: isSelected,
            onTap: method.isDisabled
                ? null
                : () =>
                    ref.read(paymentProvider.notifier).selectMethod(method.type),
            colors: colors,
          );
        }),
      ],
    );
  }
}

class _MethodTile extends StatelessWidget {
  final PaymentMethodInfo method;
  final bool isSelected;
  final VoidCallback? onTap;
  final C colors;

  const _MethodTile({
    required this.method,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isSelected
                ? method.color.withAlpha(colors.isDark ? 25 : 15)
                : colors.surface,
            borderRadius: AppRadius.lgAll,
            border: Border.all(
              color: isSelected
                  ? method.color
                  : method.isDisabled
                      ? colors.textTertiary.withAlpha(30)
                      : colors.textTertiary.withAlpha(50),
              width: isSelected ? 1.8 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: method.color.withAlpha(25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Opacity(
            opacity: method.isDisabled ? 0.4 : 1.0,
            child: Row(
              children: [
                // Icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? method.color.withAlpha(30)
                        : method.color.withAlpha(colors.isDark ? 20 : 12),
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: Icon(
                    method.icon,
                    color: method.color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.label,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        method.subtitle,
                        style: AppTextStyles.caption.copyWith(
                          color: method.isDisabled
                              ? AppColors.error
                              : colors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Radio indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? method.color
                          : colors.textTertiary.withAlpha(80),
                      width: isSelected ? 2 : 1.5,
                    ),
                    color: isSelected ? method.color : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
