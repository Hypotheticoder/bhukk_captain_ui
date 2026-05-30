import 'package:bhukkdelivery/models/snack_item.dart';
import 'package:bhukkdelivery/providers/snacks_inventory/snacks_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SnackItemCard extends ConsumerStatefulWidget {
  final SnackItem snack;
  final VoidCallback? onDismissed;

  const SnackItemCard({super.key, required this.snack, this.onDismissed});

  @override
  ConsumerState<SnackItemCard> createState() => _SnackItemCardState();
}

class _SnackItemCardState extends ConsumerState<SnackItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onQuantityChanged(int delta) {
    HapticFeedback.lightImpact();
    _pulseController.forward().then((_) => _pulseController.reverse());
    ref.read(snacksProvider.notifier).updateQuantity(widget.snack.id, delta);
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    final s = widget.snack;
    final isLowStock = s.stockCount <= 3 && s.stockCount > 0;
    final isOutOfStock = s.stockCount <= 0;

    return Dismissible(
      key: ValueKey(s.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(snacksProvider.notifier).removeItem(s.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${s.name} removed"),
            backgroundColor: AppColors.error,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.only(right: AppSpacing.xxl),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(30),
          borderRadius: AppRadius.xlAll,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete_outline_rounded,
                color: AppColors.error, size: 24),
            const SizedBox(height: 4),
            Text(
              "Delete",
              style: AppTextStyles.caption.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          return Transform.scale(scale: _pulseAnim.value, child: child);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: AppRadius.xlAll,
            border: Border.all(
              color: isOutOfStock
                  ? AppColors.error.withAlpha(40)
                  : isLowStock
                      ? AppColors.warning.withAlpha(40)
                      : colors.blush.withAlpha(colors.isDark ? 25 : 50),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.cardShadow(0.04),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Product icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary
                          .withAlpha(colors.isDark ? 40 : 20),
                      AppColors.primaryAccent
                          .withAlpha(colors.isDark ? 20 : 10),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppRadius.lgAll,
                ),
                child: Icon(
                  s.icon,
                  size: 26,
                  color: isOutOfStock
                      ? colors.textTertiary
                      : AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),

              // Name + category + price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isOutOfStock
                            ? colors.textTertiary
                            : colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.info
                                .withAlpha(colors.isDark ? 25 : 15),
                            borderRadius: AppRadius.pillAll,
                          ),
                          child: Text(
                            s.category,
                            style: AppTextStyles.overline.copyWith(
                              fontSize: 9,
                              color: AppColors.info,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          "₹${s.price.toStringAsFixed(0)}",
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (isLowStock) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withAlpha(20),
                              borderRadius: AppRadius.pillAll,
                            ),
                            child: Text(
                              "LOW",
                              style: AppTextStyles.overline.copyWith(
                                fontSize: 8,
                                color: AppColors.warning,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                        if (isOutOfStock) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withAlpha(20),
                              borderRadius: AppRadius.pillAll,
                            ),
                            child: Text(
                              "OUT",
                              style: AppTextStyles.overline.copyWith(
                                fontSize: 8,
                                color: AppColors.error,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Quantity stepper
              Container(
                decoration: BoxDecoration(
                  color: colors.blush.withAlpha(colors.isDark ? 20 : 50),
                  borderRadius: AppRadius.pillAll,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StepperButton(
                      icon: Icons.remove_rounded,
                      onTap: s.stockCount > 0
                          ? () => _onQuantityChanged(-1)
                          : null,
                      colors: colors,
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) {
                        return ScaleTransition(scale: anim, child: child);
                      },
                      child: SizedBox(
                        key: ValueKey(s.stockCount),
                        width: 36,
                        child: Text(
                          "${s.stockCount}",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.label.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isOutOfStock
                                ? AppColors.error
                                : colors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    _StepperButton(
                      icon: Icons.add_rounded,
                      onTap: () => _onQuantityChanged(1),
                      colors: colors,
                      isPrimary: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stepper Button ──
class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final C colors;
  final bool isPrimary;

  const _StepperButton({
    required this.icon,
    this.onTap,
    required this.colors,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    return Material(
      color: isPrimary
          ? (isDisabled
              ? colors.divider
              : AppColors.primary)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 16,
            color: isPrimary
                ? Colors.white
                : (isDisabled ? colors.textTertiary : colors.textPrimary),
          ),
        ),
      ),
    );
  }
}
