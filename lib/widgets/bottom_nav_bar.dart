import 'dart:ui';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';

class FloatingBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: "Home",
    ),
    _NavItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: "Orders",
    ),
    _NavItem(
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
      label: "Earnings",
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: "Profile",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return Container(
      margin: const EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: AppSpacing.xxl,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.xxlAll,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            height: 68,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: colors.isDark
                  ? Colors.white.withAlpha(15)
                  : Colors.white.withAlpha(180),
              borderRadius: AppRadius.xxlAll,
              border: Border.all(
                color: colors.isDark
                    ? Colors.white.withAlpha(20)
                    : Colors.white.withAlpha(130),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(colors.isDark ? 40 : 12),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: List.generate(_items.length, (index) {
                return Expanded(
                  flex: currentIndex == index ? 3 : 2,
                  child: _GlassNavItem(
                    item: _items[index],
                    isActive: currentIndex == index,
                    onTap: () => onTap(index),
                    colors: colors,
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassNavItem extends StatefulWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;
  final C colors;

  const _GlassNavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
    required this.colors,
  });

  @override
  State<_GlassNavItem> createState() => _GlassNavItemState();
}

class _GlassNavItemState extends State<_GlassNavItem>
    with TickerProviderStateMixin {
  late AnimationController _pillController;
  late AnimationController _rippleController;
  late Animation<double> _pillAnim;
  late Animation<double> _labelAnim;
  late Animation<double> _rippleScale;
  late Animation<double> _rippleOpacity;

  @override
  void initState() {
    super.initState();

    _pillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pillAnim = CurvedAnimation(
      parent: _pillController,
      curve: Curves.easeOutCubic,
    );
    _labelAnim = CurvedAnimation(
      parent: _pillController,
      curve: const Interval(0.25, 1.0, curve: Curves.easeOut),
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _rippleScale = Tween<double>(begin: 0.0, end: 2.5).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOutCubic),
    );
    _rippleOpacity = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _rippleController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    if (widget.isActive) {
      _pillController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant _GlassNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _pillController.forward(from: 0);
      _rippleController.forward(from: 0);
    } else if (!widget.isActive && oldWidget.isActive) {
      _pillController.reverse();
    }
  }

  @override
  void dispose() {
    _pillController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pillController, _rippleController]),
        builder: (context, _) {
          final p = _pillAnim.value;

          return SizedBox(
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Glass pill behind active item
                if (p > 0.01)
                  Positioned(
                    left: 6,
                    right: 6,
                    top: 6,
                    bottom: 6,
                    child: Opacity(
                      opacity: p,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.pillAll,
                          color: widget.colors.isDark
                              ? AppColors.primary.withAlpha(45)
                              : AppColors.primary.withAlpha(18),
                          border: Border.all(
                            color: AppColors.primary.withAlpha(
                              widget.colors.isDark ? 40 : 25,
                            ),
                            width: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Water ripple
                if (_rippleController.isAnimating)
                  Opacity(
                    opacity: _rippleOpacity.value.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: _rippleScale.value,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withAlpha(60),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Icon + sliding label
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeIn,
                      child: Icon(
                        widget.isActive
                            ? widget.item.activeIcon
                            : widget.item.icon,
                        key: ValueKey(widget.isActive),
                        size: 22,
                        color: widget.isActive
                            ? AppColors.primary
                            : widget.colors.textTertiary,
                      ),
                    ),
                    // Slide-in label
                    Flexible(
                      child: ClipRect(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          width: widget.isActive ? 48 : 0,
                          child: Opacity(
                            opacity: _labelAnim.value.clamp(0.0, 1.0),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                widget.item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Bottom droplet dot
                Positioned(
                  bottom: 1,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: widget.isActive ? 5 : 0,
                    height: widget.isActive ? 5 : 0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      boxShadow: widget.isActive
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(80),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ]
                          : [],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
