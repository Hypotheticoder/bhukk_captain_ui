import 'package:bhukkdelivery/providers/help_support/help_support_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FaqAccordionCard extends ConsumerWidget {
  const FaqAccordionCard({super.key});

  // Category accent colors
  static const Map<String, Color> _categoryColors = {
    'Payments': AppColors.success,
    'Orders': AppColors.warning,
    'Account': AppColors.info,
    'Navigation': AppColors.purple,
    'Safety': AppColors.error,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = C.of(context);
    final state = ref.watch(helpSupportProvider);
    final faqs = state.filteredFaqs;

    if (faqs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        decoration: colors.card,
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 44,
              color: colors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              "No results found",
              style: AppTextStyles.bodyMd.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              "Try a different search or category",
              style: AppTextStyles.caption.copyWith(
                color: colors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: colors.card,
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: List.generate(faqs.length, (index) {
          return _AnimatedFaqItem(
            faq: faqs[index],
            colors: colors,
            accentColor: _categoryColors[faqs[index].category] ?? AppColors.primary,
            isLast: index == faqs.length - 1,
            animationIndex: index,
          );
        }),
      ),
    );
  }
}

class _AnimatedFaqItem extends StatefulWidget {
  final FaqItem faq;
  final C colors;
  final Color accentColor;
  final bool isLast;
  final int animationIndex;

  const _AnimatedFaqItem({
    required this.faq,
    required this.colors,
    required this.accentColor,
    required this.isLast,
    required this.animationIndex,
  });

  @override
  State<_AnimatedFaqItem> createState() => _AnimatedFaqItemState();
}

class _AnimatedFaqItemState extends State<_AnimatedFaqItem>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _iconController;
  late Animation<double> _iconTurn;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _iconTurn = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _iconController.forward();
      } else {
        _iconController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + widget.animationIndex * 80),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          InkWell(
            onTap: _handleTap,
            child: Container(
              decoration: BoxDecoration(
                border: !widget.isLast && !_isExpanded
                    ? Border(
                        bottom: BorderSide(
                          color: widget.colors.divider,
                          width: 0.5,
                        ),
                      )
                    : null,
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // Colored accent bar
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      width: 3.5,
                      decoration: BoxDecoration(
                        color: _isExpanded
                            ? widget.accentColor
                            : widget.accentColor.withAlpha(0),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(2),
                          bottomRight: Radius.circular(2),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.lg + 2,
                        ),
                        child: Row(
                          children: [
                            // Category dot
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.accentColor.withAlpha(
                                  widget.colors.isDark ? 120 : 150,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                widget.faq.question,
                                style: AppTextStyles.bodyMd.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: widget.colors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            RotationTransition(
                              turns: _iconTurn,
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 22,
                                color: _isExpanded
                                    ? widget.accentColor
                                    : widget.colors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Answer
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                left: AppSpacing.xl + AppSpacing.lg,
                right: AppSpacing.xl,
                bottom: AppSpacing.xl,
              ),
              decoration: BoxDecoration(
                color: widget.accentColor.withAlpha(
                  widget.colors.isDark ? 10 : 6,
                ),
                border: !widget.isLast
                    ? Border(
                        bottom: BorderSide(
                          color: widget.colors.divider,
                          width: 0.5,
                        ),
                      )
                    : null,
              ),
              child: Text(
                widget.faq.answer,
                style: AppTextStyles.bodySm.copyWith(
                  color: widget.colors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
            sizeCurve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }
}
