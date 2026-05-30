import 'package:bhukkdelivery/cards/snacks_inventory_screen/add_item_bottom_sheet.dart';
import 'package:bhukkdelivery/cards/snacks_inventory_screen/snack_item_card.dart';
import 'package:bhukkdelivery/cards/snacks_inventory_screen/snacks_header_card.dart';
import 'package:bhukkdelivery/providers/snacks_inventory/snacks_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SnacksInventoryScreen extends ConsumerStatefulWidget {
  const SnacksInventoryScreen({super.key});

  @override
  ConsumerState<SnacksInventoryScreen> createState() =>
      _SnacksInventoryScreenState();
}

class _SnacksInventoryScreenState extends ConsumerState<SnacksInventoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Animation<double> _staggeredFade(int index) {
    final start = (index * 0.08).clamp(0.0, 0.7);
    final end = (start + 0.3).clamp(0.0, 1.0);
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  Animation<Offset> _staggeredSlide(int index) {
    final start = (index * 0.08).clamp(0.0, 0.7);
    final end = (start + 0.3).clamp(0.0, 1.0);
    return Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  void _openAddItemSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddItemBottomSheet(),
    );
  }

  void _handleSave() async {
    HapticFeedback.lightImpact();
    await ref.read(snacksProvider.notifier).saveInventory();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Inventory saved successfully!"),
          backgroundColor: AppColors.success,
          duration: Duration(milliseconds: 1500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    final state = ref.watch(snacksProvider);
    final filteredSnacks = state.filteredSnacks;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          "Inventory",
          style: AppTextStyles.headingSm.copyWith(color: colors.textPrimary),
        ),
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: AppRadius.mdAll,
              boxShadow: [
                BoxShadow(
                  color: colors.cardShadow(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: colors.textPrimary,
              size: 22,
            ),
          ),
        ),
        actions: [
          // Add item button
          GestureDetector(
            onTap: _openAddItemSheet,
            child: Container(
              margin: const EdgeInsets.only(right: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.pillAll,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(60),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    "Add",
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Save button
          GestureDetector(
            onTap: state.isSaving ? null : _handleSave,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: AppSpacing.lg),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: state.isSaving
                    ? AppColors.success.withAlpha(20)
                    : AppColors.success.withAlpha(colors.isDark ? 30 : 15),
                borderRadius: AppRadius.pillAll,
                border: Border.all(
                  color: AppColors.success.withAlpha(60),
                  width: 0.5,
                ),
              ),
              child: state.isSaving
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.success,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.save_rounded,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          "Save",
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _staggerController,
        builder: (context, _) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.xl,
                    right: AppSpacing.xl,
                    top: AppSpacing.md,
                    bottom: AppSpacing.lg,
                  ),
                  child: SlideTransition(
                    position: _staggeredSlide(0),
                    child: FadeTransition(
                      opacity: _staggeredFade(0),
                      child: SnacksHeaderCard(state: state),
                    ),
                  ),
                ),
              ),

              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: SlideTransition(
                    position: _staggeredSlide(1),
                    child: FadeTransition(
                      opacity: _staggeredFade(1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.surfaceElevated,
                          borderRadius: AppRadius.lgAll,
                          boxShadow: [
                            BoxShadow(
                              color: colors.cardShadow(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocus,
                          onChanged: (v) {
                            ref
                                .read(snacksProvider.notifier)
                                .setSearchQuery(v);
                          },
                          style: AppTextStyles.bodySm.copyWith(
                            color: colors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: "Search products...",
                            hintStyle: AppTextStyles.bodySm.copyWith(
                              color: colors.textTertiary,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: colors.textTertiary,
                              size: 22,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? GestureDetector(
                                    onTap: () {
                                      _searchController.clear();
                                      ref
                                          .read(snacksProvider.notifier)
                                          .setSearchQuery('');
                                    },
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: colors.textTertiary,
                                      size: 18,
                                    ),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md + 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.lg),
              ),

              // Categories Filter
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _staggeredSlide(2),
                  child: FadeTransition(
                    opacity: _staggeredFade(2),
                    child: SizedBox(
                      height: 40,
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl),
                        scrollDirection: Axis.horizontal,
                        itemCount: state.categories.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final category = state.categories[index];
                          final isSelected =
                              category == state.selectedCategory;
                          return GestureDetector(
                            onTap: () {
                              ref
                                  .read(snacksProvider.notifier)
                                  .selectCategory(category);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : colors.surfaceElevated,
                                borderRadius: AppRadius.pillAll,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : colors.divider,
                                  width: isSelected ? 1.5 : 0.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color:
                                              AppColors.primary.withAlpha(40),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                category,
                                style: AppTextStyles.caption.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : colors.textSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.lg),
              ),

              // Item count label
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: SlideTransition(
                    position: _staggeredSlide(3),
                    child: FadeTransition(
                      opacity: _staggeredFade(3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${filteredSnacks.length} item${filteredSnacks.length != 1 ? 's' : ''}",
                            style: AppTextStyles.caption.copyWith(
                              color: colors.textTertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Swipe left to delete",
                            style: AppTextStyles.overline.copyWith(
                              fontSize: 10,
                              color: colors.textTertiary.withAlpha(160),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.md),
              ),

              // Items list
              filteredSnacks.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.huge),
                        child: Center(
                          child: Column(
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration:
                                    const Duration(milliseconds: 800),
                                curve: Curves.elasticOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                      scale: value, child: child);
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.all(AppSpacing.xl),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colors.blush
                                        .withAlpha(colors.isDark ? 25 : 60),
                                  ),
                                  child: Icon(
                                    Icons.inventory_2_outlined,
                                    size: 48,
                                    color:
                                        colors.textTertiary.withAlpha(120),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                state.searchQuery.isNotEmpty
                                    ? "No results found"
                                    : "No products yet",
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: colors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                state.searchQuery.isNotEmpty
                                    ? "Try a different search term"
                                    : "Tap + to add your first item",
                                style: AppTextStyles.caption.copyWith(
                                  color: colors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return SlideTransition(
                              position: _staggeredSlide(index + 4),
                              child: FadeTransition(
                                opacity: _staggeredFade(index + 4),
                                child: SnackItemCard(
                                  snack: filteredSnacks[index],
                                ),
                              ),
                            );
                          },
                          childCount: filteredSnacks.length,
                        ),
                      ),
                    ),

              // Bottom padding for FAB
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          );
        },
      ),
    );
  }
}
