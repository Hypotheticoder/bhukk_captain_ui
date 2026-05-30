import 'package:bhukkdelivery/models/vehicle_types.dart';
import 'package:bhukkdelivery/providers/edit_profile/edit_profile_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VehicleDetailsFormCard extends ConsumerWidget {
  const VehicleDetailsFormCard({super.key});

  String _getDisplayName(String val) {
    for (final v in kBackendVehicles) {
      if (v.dbValue == val) return v.displayName;
    }
    switch (val) {
      case 'Bike (Motorcycle/Scooter)':
        return 'Bike / Motorcycle';
      case 'Auto Rickshaw (3-Wheeler)':
        return 'Auto Rickshaw (3-Wheeler)';
      case 'Normal Car (Hatchback/Sedan)':
        return 'Normal Car (Hatchback/Sedan)';
      case 'Premium Car (Fast/AC Sedan)':
        return 'Premium Car (AC Sedan)';
      case 'XL Car (SUV/6-Seater)':
        return 'XL Car (SUV/6-Seater)';
      case 'Premium XL Car (Luxury SUV)':
        return 'Premium XL Car (Luxury SUV)';
      case 'Mini Truck (Tata Ace/Chota Hathi)':
        return 'Mini Truck';
      case 'Heavy Truck':
        return 'Heavy Truck';
      default:
        return val;
    }
  }

  IconData _iconForType(String typeOrDbVal) {
    for (final v in kBackendVehicles) {
      if (v.dbValue == typeOrDbVal || v.displayName == typeOrDbVal) return v.icon;
    }
    return Icons.two_wheeler_rounded;
  }

  void _showVehicleTypeSelector(
    BuildContext context,
    WidgetRef ref,
    String currentValue,
    C colors,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  "Select Vehicle Type",
                  style: AppTextStyles.headingSm.copyWith(color: colors.textPrimary),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: kBackendVehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = kBackendVehicles[index];
                    final isSelected = vehicle.dbValue == currentValue;
                    
                    Color badgeBgColor;
                    Color badgeTextColor;
                    if (vehicle.eligibleServices.contains("Ride Booking & Parcel")) {
                      badgeBgColor = AppColors.success.withAlpha(25);
                      badgeTextColor = AppColors.success;
                    } else if (vehicle.eligibleServices.contains("Ride")) {
                      badgeBgColor = AppColors.primary.withAlpha(25);
                      badgeTextColor = AppColors.primary;
                    } else {
                      badgeBgColor = Colors.orange.withAlpha(25);
                      badgeTextColor = Colors.orange.shade700;
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: isSelected ? colors.surfaceElevated : Colors.transparent,
                        borderRadius: AppRadius.mdAll,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          vehicle.icon,
                          color: isSelected ? AppColors.primary : colors.textSecondary,
                        ),
                        title: Text(
                          vehicle.displayName,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: isSelected ? AppColors.primary : colors.textPrimary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicle.description,
                              style: AppTextStyles.caption.copyWith(color: colors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: badgeBgColor,
                                borderRadius: AppRadius.smAll,
                              ),
                              child: Text(
                                vehicle.eligibleServices,
                                style: AppTextStyles.caption.copyWith(
                                  color: badgeTextColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                            : null,
                        onTap: () {
                          ref.read(editProfileProvider.notifier).updateVehicleType(vehicle.dbValue);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Vehicle Type",
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textTertiary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: () => _showVehicleTypeSelector(context, ref, state.vehicleType, colors),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md + 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.blush.withAlpha(colors.isDark ? 30 : 60),
                    borderRadius: AppRadius.lgAll,
                    border: Border.all(
                      color: colors.blush.withAlpha(colors.isDark ? 50 : 120),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _iconForType(state.vehicleType),
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          _getDisplayName(state.vehicleType),
                          style: AppTextStyles.bodyMd.copyWith(color: colors.textPrimary),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: colors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _VehicleField(
            label: "Vehicle Number",
            icon: Icons.pin_outlined,
            initialValue: state.vehicleNumber,
            onChanged: (v) =>
                ref.read(editProfileProvider.notifier).updateVehicleNumber(v),
            colors: colors,
            hint: "e.g. MH-12 AB 1234",
          ),
        ],
      ),
    );
  }
}

class _VehicleField extends StatefulWidget {
  final String label;
  final IconData icon;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final C colors;
  final String? hint;

  const _VehicleField({
    required this.label,
    required this.icon,
    required this.initialValue,
    required this.onChanged,
    required this.colors,
    this.hint,
  });

  @override
  State<_VehicleField> createState() => _VehicleFieldState();
}

class _VehicleFieldState extends State<_VehicleField> {
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _VehicleField oldWidget) {
    super.didUpdateWidget(oldWidget);
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
              onChanged: widget.onChanged,
              textCapitalization: TextCapitalization.characters,
              style: AppTextStyles.bodyMd.copyWith(color: c.textPrimary),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  widget.icon,
                  size: 20,
                  color: _isFocused ? AppColors.primary : c.textTertiary,
                ),
                hintText: widget.hint,
                hintStyle: AppTextStyles.bodySm.copyWith(
                  color: c.textTertiary.withAlpha(120),
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
