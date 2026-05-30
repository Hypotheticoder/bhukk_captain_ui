import 'package:bhukkdelivery/models/snack_item.dart';
import 'package:bhukkdelivery/providers/snacks_inventory/snacks_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddItemBottomSheet extends ConsumerStatefulWidget {
  const AddItemBottomSheet({super.key});

  @override
  ConsumerState<AddItemBottomSheet> createState() => _AddItemBottomSheetState();
}

class _AddItemBottomSheetState extends ConsumerState<AddItemBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  int _quantity = 1;
  String _selectedCategory = 'Chips';
  IconData _selectedIcon = Icons.fastfood_rounded;

  static const _categories = ['Chips', 'Beverages', 'Sweets', 'Biscuits', 'Other'];

  static const _availableIcons = [
    Icons.fastfood_rounded,
    Icons.local_cafe_rounded,
    Icons.local_drink_rounded,
    Icons.cookie_rounded,
    Icons.icecream_rounded,
    Icons.bakery_dining_rounded,
    Icons.lunch_dining_rounded,
    Icons.breakfast_dining_rounded,
    Icons.set_meal_rounded,
    Icons.sports_bar_rounded,
    Icons.brunch_dining_rounded,
    Icons.ramen_dining_rounded,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(snacksProvider.notifier);
    final item = SnackItem(
      id: notifier.generateId(),
      name: _nameController.text.trim(),
      category: _selectedCategory,
      price: double.tryParse(_priceController.text) ?? 0,
      stockCount: _quantity,
      icon: _selectedIcon,
    );

    notifier.addItem(item);
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${item.name} added to inventory!"),
        backgroundColor: AppColors.success,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: AppSpacing.md,
          bottom: MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).padding.bottom +
              100,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: AppRadius.pillAll,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm + 2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withAlpha(colors.isDark ? 40 : 20),
                          AppColors.primaryAccent
                              .withAlpha(colors.isDark ? 20 : 10),
                        ],
                      ),
                      borderRadius: AppRadius.mdAll,
                    ),
                    child: const Icon(
                      Icons.add_shopping_cart_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    "Add New Item",
                    style: AppTextStyles.headingSm.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Product Name
              _buildLabel("Product Name", colors),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _nameController,
                style: AppTextStyles.bodySm.copyWith(
                  color: colors.textPrimary,
                ),
                decoration: _inputDecoration(
                  colors,
                  hint: "e.g. Lays Classic",
                  icon: Icons.label_outline_rounded,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Name is required" : null,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Category
              _buildLabel("Category", colors),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                style: AppTextStyles.bodySm.copyWith(
                  color: colors.textPrimary,
                ),
                dropdownColor: colors.surfaceElevated,
                decoration: _inputDecoration(
                  colors,
                  hint: "Select category",
                  icon: Icons.category_outlined,
                ),
                items: _categories.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCategory = v);
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // Price
              _buildLabel("Price (₹)", colors),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: AppTextStyles.bodySm.copyWith(
                  color: colors.textPrimary,
                ),
                decoration: _inputDecoration(
                  colors,
                  hint: "e.g. 25",
                  icon: Icons.currency_rupee_rounded,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Price is required";
                  if (double.tryParse(v) == null) return "Enter a valid number";
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // Quantity
              _buildLabel("Initial Quantity", colors),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: colors.blush.withAlpha(colors.isDark ? 20 : 50),
                  borderRadius: AppRadius.lgAll,
                  border: Border.all(
                    color: colors.divider,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQtyButton(
                      Icons.remove_rounded,
                      _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                      colors,
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) {
                        return ScaleTransition(scale: anim, child: child);
                      },
                      child: Text(
                        "$_quantity",
                        key: ValueKey(_quantity),
                        style: AppTextStyles.headingSm.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _buildQtyButton(
                      Icons.add_rounded,
                      () => setState(() => _quantity++),
                      colors,
                      isPrimary: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Icon picker
              _buildLabel("Icon", colors),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableIcons.length,
                  separatorBuilder: (context, i) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final icon = _availableIcons[index];
                    final isSelected = icon == _selectedIcon;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                                  .withAlpha(colors.isDark ? 50 : 25)
                              : colors.blush
                                  .withAlpha(colors.isDark ? 15 : 40),
                          borderRadius: AppRadius.mdAll,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          icon,
                          size: 22,
                          color: isSelected
                              ? AppColors.primary
                              : colors.textTertiary,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Submit button
              GestureDetector(
                onTap: _submit,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: AppButtonStyles.primaryButton,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.textOnPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          "Add to Inventory",
                          style: AppTextStyles.buttonText.copyWith(
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, C colors) {
    return Text(
      text,
      style: AppTextStyles.label.copyWith(
        color: colors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _inputDecoration(C colors,
      {required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodySm.copyWith(
        color: colors.textTertiary,
      ),
      prefixIcon: Icon(icon, size: 20, color: colors.textTertiary),
      filled: true,
      fillColor: colors.blush.withAlpha(colors.isDark ? 20 : 50),
      border: OutlineInputBorder(
        borderRadius: AppRadius.lgAll,
        borderSide: BorderSide(color: colors.divider, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.lgAll,
        borderSide: BorderSide(color: colors.divider, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.lgAll,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.lgAll,
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md + 2,
      ),
    );
  }

  Widget _buildQtyButton(
    IconData icon,
    VoidCallback? onTap,
    C colors, {
    bool isPrimary = false,
  }) {
    final isDisabled = onTap == null;
    return Material(
      color: isPrimary
          ? (isDisabled ? colors.divider : AppColors.primary)
          : colors.surfaceElevated,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18,
            color: isPrimary
                ? Colors.white
                : (isDisabled ? colors.textTertiary : colors.textPrimary),
          ),
        ),
      ),
    );
  }
}
