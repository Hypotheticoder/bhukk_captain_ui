import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:bhukkdelivery/widgets/support_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactOptionsCard extends ConsumerWidget {
  const ContactOptionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = C.of(context);

    final options = [
      _ContactOption(
        icon: Icons.phone_outlined,
        title: 'Call Us',
        subtitle: 'Available 24/7',
        color: AppColors.success,
        onTap: () => showSupportPopup(context),
      ),
      _ContactOption(
        icon: Icons.email_outlined,
        title: 'Email Us',
        subtitle: 'Within 24 hrs',
        color: AppColors.info,
        onTap: () {},
      ),
    ];

    return Row(
      children: List.generate(options.length, (index) {
        final option = options[index];
        return Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 500 + index * 120),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 18 * (1 - value)),
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : AppSpacing.sm / 2,
                right: index == options.length - 1 ? 0 : AppSpacing.sm / 2,
              ),
              child: _ContactOptionTile(option: option, colors: colors),
            ),
          ),
        );
      }),
    );
  }
}

class _ContactOptionTile extends StatefulWidget {
  final _ContactOption option;
  final C colors;

  const _ContactOptionTile({required this.option, required this.colors});

  @override
  State<_ContactOptionTile> createState() => _ContactOptionTileState();
}

class _ContactOptionTileState extends State<_ContactOptionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.option;
    final c = widget.colors;

    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        o.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnim.value, child: child);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xl,
            horizontal: AppSpacing.sm,
          ),
          decoration: c.card,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      o.color.withAlpha(c.isDark ? 50 : 30),
                      o.color.withAlpha(c.isDark ? 25 : 12),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppRadius.mdAll,
                ),
                child: Icon(o.icon, color: o.color, size: 26),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                o.title,
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                o.subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: c.textTertiary,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ContactOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}
