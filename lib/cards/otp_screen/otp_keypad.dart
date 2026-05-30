import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpKeypad extends StatelessWidget {
  final void Function(String digit) onDigit;
  final VoidCallback onDelete;
  final VoidCallback onClear;

  const OtpKeypad({
    super.key,
    required this.onDigit,
    required this.onDelete,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return Column(
      children: [
        _buildRow(['1', '2', '3'], colors),
        const SizedBox(height: AppSpacing.md),
        _buildRow(['4', '5', '6'], colors),
        const SizedBox(height: AppSpacing.md),
        _buildRow(['7', '8', '9'], colors),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _buildActionKey(
              icon: Icons.refresh_rounded,
              label: "Clear",
              onTap: () {
                HapticFeedback.lightImpact();
                onClear();
              },
              colors: colors,
            ),
            const SizedBox(width: AppSpacing.md),
            _buildDigitKey('0', colors),
            const SizedBox(width: AppSpacing.md),
            _buildActionKey(
              icon: Icons.backspace_outlined,
              label: "",
              onTap: () {
                HapticFeedback.lightImpact();
                onDelete();
              },
              colors: colors,
              isDelete: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> digits, C colors) {
    return Row(
      children: digits.asMap().entries.map((entry) {
        final widgets = <Widget>[];
        if (entry.key > 0) {
          widgets.add(const SizedBox(width: AppSpacing.md));
        }
        widgets.add(_buildDigitKey(entry.value, colors));
        return Expanded(child: Row(children: widgets));
      }).toList(),
    );
  }

  Widget _buildDigitKey(String digit, C colors) {
    return Expanded(
      child: _KeyButton(
        onTap: () {
          HapticFeedback.selectionClick();
          onDigit(digit);
        },
        colors: colors,
        child: Text(
          digit,
          style: AppTextStyles.headingSm.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required C colors,
    bool isDelete = false,
  }) {
    return Expanded(
      child: _KeyButton(
        onTap: onTap,
        isAction: true,
        colors: colors,
        child: Icon(
          icon,
          size: 22,
          color: isDelete ? AppColors.error : colors.textSecondary,
        ),
      ),
    );
  }
}

class _KeyButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  final bool isAction;
  final C colors;

  const _KeyButton({
    required this.onTap,
    required this.child,
    this.isAction = false,
    required this.colors,
  });

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnim.value, child: child);
        },
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: widget.isAction
                ? widget.colors.blush.withAlpha(widget.colors.isDark ? 20 : 50)
                : widget.colors.surfaceElevated,
            borderRadius: AppRadius.lgAll,
            border: Border.all(
              color: widget.colors.divider.withAlpha(
                  widget.colors.isDark ? 30 : 60),
              width: 0.5,
            ),
            boxShadow: widget.isAction
                ? null
                : [
                    BoxShadow(
                      color: widget.colors.cardShadow(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
