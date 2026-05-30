import 'package:bhukkdelivery/models/vehicle_types.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VehicleInfoCard extends StatelessWidget {
  final String selectedType;
  final TextEditingController brandController;
  final TextEditingController modelController;
  final TextEditingController yearController;
  final TextEditingController numberController;
  final TextEditingController colorController;
  final ValueChanged<String> onTypeChanged;
  final String? errorMessage;

  const VehicleInfoCard({
    super.key,
    required this.selectedType,
    required this.brandController,
    required this.modelController,
    required this.yearController,
    required this.numberController,
    required this.colorController,
    required this.onTypeChanged,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Vehicle type selector title
        Text(
          "Vehicle Type",
          style: AppTextStyles.caption.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        // Detailed Card-based selector
        Column(
          children: kBackendVehicles.map((vehicle) {
            final isSelected = selectedType == vehicle.dbValue;
            
            // Define service badge colors
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

            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onTypeChanged(vehicle.dbValue);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.surfaceElevated
                      : colors.surface,
                  borderRadius: AppRadius.lgAll,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : colors.divider.withAlpha(80),
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? AppColors.primary.withAlpha(30)
                          : colors.cardShadow(0.02),
                      blurRadius: isSelected ? 12 : 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vehicle Icon Backdrop
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withAlpha(30)
                            : colors.surfaceElevated,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        vehicle.icon,
                        size: 24,
                        color: isSelected ? AppColors.primary : colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    
                    // Vehicle Info details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.displayName,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: colors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            "Fits: ${vehicle.description}",
                            style: AppTextStyles.caption.copyWith(
                              color: colors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          
                          // Eligible Services Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs - 1,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBgColor,
                              borderRadius: AppRadius.smAll,
                            ),
                            child: Text(
                              vehicle.eligibleServices,
                              style: AppTextStyles.caption.copyWith(
                                color: badgeTextColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Radio indicator
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : colors.textTertiary,
                          width: isSelected ? 6 : 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _buildField(context,
            label: "Brand",
            hint: "e.g. Honda, TVS, Hero",
            icon: Icons.branding_watermark_rounded,
            controller: brandController),
        const SizedBox(height: AppSpacing.xl),
        _buildField(context,
            label: "Model",
            hint: "e.g. Activa, Splendor",
            icon: Icons.edit_rounded,
            controller: modelController),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: _buildField(context,
                  label: "Year",
                  hint: "e.g. 2022",
                  icon: Icons.calendar_today_rounded,
                  controller: yearController,
                  keyboardType: TextInputType.number,
                  maxLength: 4),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildField(context,
                  label: "Color",
                  hint: "e.g. Black",
                  icon: Icons.palette_outlined,
                  controller: colorController),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildField(context,
            label: "Registration Number",
            hint: "e.g. MH 01 AB 1234",
            icon: Icons.confirmation_number_outlined,
            controller: numberController,
            textCapitalization: TextCapitalization.characters),

        if (errorMessage != null && errorMessage!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.error.withAlpha(12),
              borderRadius: AppRadius.mdAll,
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.error, size: 16),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildField(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    final colors = C.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: colors.divider, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: colors.cardShadow(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            maxLength: maxLength,
            style: AppTextStyles.bodySm.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: hint,
              hintStyle: AppTextStyles.bodySm.copyWith(
                color: colors.textTertiary,
              ),
              prefixIcon: Icon(icon, color: colors.textTertiary, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md + 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
