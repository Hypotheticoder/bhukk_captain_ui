import 'package:bhukkdelivery/providers/edit_profile/edit_profile_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PersonalDetailsFormCard extends ConsumerWidget {
  const PersonalDetailsFormCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = C.of(context);
    final state = ref.watch(editProfileProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: colors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StyledField(
            label: "Full Name",
            icon: Icons.person_outline_rounded,
            initialValue: state.name,
            onChanged: (v) =>
                ref.read(editProfileProvider.notifier).updateName(v),
            colors: colors,
          ),
          const SizedBox(height: AppSpacing.lg),
          _StyledField(
            label: "Phone Number",
            icon: Icons.phone_outlined,
            initialValue: state.phone,
            keyboardType: TextInputType.phone,
            onChanged: (v) =>
                ref.read(editProfileProvider.notifier).updatePhone(v),
            colors: colors,
          ),
          const SizedBox(height: AppSpacing.lg),
          _StyledField(
            label: "Email Address",
            icon: Icons.email_outlined,
            initialValue: state.email,
            keyboardType: TextInputType.emailAddress,
            onChanged: (v) =>
                ref.read(editProfileProvider.notifier).updateEmail(v),
            colors: colors,
          ),
        ],
      ),
    );
  }
}

class _StyledField extends StatefulWidget {
  final String label;
  final IconData icon;
  final String initialValue;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;
  final C colors;

  const _StyledField({
    required this.label,
    required this.icon,
    required this.initialValue,
    this.keyboardType,
    required this.onChanged,
    required this.colors,
  });

  @override
  State<_StyledField> createState() => _StyledFieldState();
}

class _StyledFieldState extends State<_StyledField> {
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _StyledField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if the text didn't originate from this controller
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: _isFocused ? AppColors.primary : c.textTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Focus(
          onFocusChange: (f) => setState(() => _isFocused = f),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: c.blush.withAlpha(c.isDark ? 30 : 60),
              borderRadius: AppRadius.lgAll,
              border: Border.all(
                color: _isFocused
                    ? AppColors.primary.withAlpha(c.isDark ? 120 : 80)
                    : c.blush.withAlpha(c.isDark ? 50 : 120),
                width: _isFocused ? 1.5 : 1,
              ),
            ),
            child: TextField(
              controller: _controller,
              keyboardType: widget.keyboardType,
              onChanged: widget.onChanged,
              style: AppTextStyles.bodyMd.copyWith(color: c.textPrimary),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  widget.icon,
                  size: 20,
                  color: _isFocused ? AppColors.primary : c.textTertiary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md + 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
