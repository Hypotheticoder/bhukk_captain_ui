import 'package:bhukkdelivery/cards/earning_screen/earnings_breakdown_card.dart';
import 'package:bhukkdelivery/cards/earning_screen/earnings_total_card.dart';
import 'package:bhukkdelivery/cards/earning_screen/gst_breakdown_card.dart';
import 'package:bhukkdelivery/notifiers/orders_screen/orders_notifier.dart';
import 'package:bhukkdelivery/providers/earnings/earnings_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:bhukkdelivery/cards/home/promo_ads_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;

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
    super.dispose();
  }

  Animation<double> _staggeredFade(int index) {
    final start = (index * 0.10).clamp(0.0, 0.7);
    final end = (start + 0.3).clamp(0.0, 1.0);
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  Animation<Offset> _staggeredSlide(int index) {
    final start = (index * 0.10).clamp(0.0, 0.7);
    final end = (start + 0.3).clamp(0.0, 1.0);
    return Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    final state = ref.watch(earningsProvider);
    final selectedService = state.selectedServiceIndex;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _staggerController,
          builder: (context, _) {
            return RefreshIndicator(
              onRefresh: () => ref.read(earningsProvider.notifier).refresh(),
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.only(
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                  top: AppSpacing.xl,
                  bottom: 120,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.md),
                        child: LinearProgressIndicator(
                          minHeight: 2,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    // ── Header ──
                    SlideTransition(
                      position: _staggeredSlide(0),
                      child: FadeTransition(
                        opacity: _staggeredFade(0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Earnings",
                              style: AppTextStyles.headingLg.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  context.push('/earnings/earning_details'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.pillAll,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Details",
                                    style: AppTextStyles.bodySm.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 12,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SlideTransition(
                      position: _staggeredSlide(0),
                      child: FadeTransition(
                        opacity: _staggeredFade(0),
                        child: Text(
                          "${state.selectedServiceLabel} services • Your earning breakdown",
                          style: AppTextStyles.bodySm.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Service filter chips ──
                    SlideTransition(
                      position: _staggeredSlide(1),
                      child: FadeTransition(
                        opacity: _staggeredFade(1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "SERVICE",
                              style: AppTextStyles.overline.copyWith(
                                color: colors.textTertiary,
                                fontSize: 10,
                                letterSpacing: 1.8,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            SizedBox(
                              height: 40,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: state.availableFilters.length,
                                separatorBuilder: (_, index) =>
                                    const SizedBox(width: AppSpacing.sm),
                                itemBuilder: (context, index) {
                                  final isActive = index == selectedService;
                                  final label = state.availableFilters[index];
                                  final svcKey = label.toLowerCase();

                                  // Custom mapping for Ride and Parcel icons/colors if not in meta
                                  Color color;
                                  IconData icon;

                                  if (svcKey == 'all') {
                                    color = AppColors.primary;
                                    icon = Icons.apps_rounded;
                                  } else if (svcKey == 'ride') {
                                    color = AppColors.primary;
                                    icon = Icons.electric_moped_rounded;
                                  } else if (svcKey == 'parcel') {
                                    color = AppColors.success;
                                    icon = Icons.inventory_2_rounded;
                                  } else {
                                    final meta = serviceMetaMap[svcKey];
                                    color = meta?.color ?? AppColors.primary;
                                    icon = meta?.icon ?? Icons.apps_rounded;
                                  }

                                  return GestureDetector(
                                    onTap: () => ref
                                        .read(earningsProvider.notifier)
                                        .selectServiceFilter(index),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeOutCubic,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md + 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? color
                                            : colors.surfaceElevated,
                                        borderRadius: AppRadius.pillAll,
                                        boxShadow: isActive
                                            ? [
                                                BoxShadow(
                                                  color: color.withAlpha(80),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                            : [
                                                BoxShadow(
                                                  color: colors.cardShadow(
                                                    0.03,
                                                  ),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            index == 0
                                                ? Icons.apps_rounded
                                                : icon,
                                            size: 14,
                                            color: isActive
                                                ? Colors.white
                                                : colors.textTertiary,
                                          ),
                                          const SizedBox(
                                            width: AppSpacing.xs + 2,
                                          ),
                                          Text(
                                            label,
                                            style: AppTextStyles.caption
                                                .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: isActive
                                                      ? Colors.white
                                                      : colors.textSecondary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Total card ──
                    SlideTransition(
                      position: _staggeredSlide(2),
                      child: FadeTransition(
                        opacity: _staggeredFade(2),
                        child: const EarningsTotalCard(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Breakdown cards ──
                    SlideTransition(
                      position: _staggeredSlide(3),
                      child: FadeTransition(
                        opacity: _staggeredFade(3),
                        child: const EarningsBreakdownCard(),
                      ),
                    ),

                    // ── GST & Fee Structure card ──
                    SlideTransition(
                      position: _staggeredSlide(4),
                      child: FadeTransition(
                        opacity: _staggeredFade(4),
                        child: const GstBreakdownCard(),
                      ),
                    ),

                    // ── Recent transactions ──
                    SlideTransition(
                      position: _staggeredSlide(5),
                      child: FadeTransition(
                        opacity: _staggeredFade(5),
                        child: _TransactionsSection(colors: colors),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Promo ads ──
                    SlideTransition(
                      position: _staggeredSlide(6),
                      child: FadeTransition(
                        opacity: _staggeredFade(6),
                        child: const PromoAdsCard(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// ── Inline transaction section (replaces a separate card) ──
class _TransactionsSection extends ConsumerWidget {
  final C colors;

  const _TransactionsSection({required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txns = ref.watch(earningsProvider.select((s) => s.transactions));

    if (txns.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Text(
          "Recent Transactions",
          style: AppTextStyles.bodyLg.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: colors.card,
          clipBehavior: Clip.hardEdge,
          child: Column(
            children: List.generate(txns.length, (index) {
              final t = txns[index];
              final isPositive = t.type != 'fee';

              IconData iconData;
              Color iconColor;
              if (t.type == 'payout') {
                iconData = t.paymentMode == 'cod'
                    ? Icons.payments_rounded
                    : Icons.credit_card_rounded;
                iconColor = AppColors.success;
              } else if (t.type == 'fee') {
                iconData = Icons.money_off_rounded;
                iconColor = AppColors.error;
              } else if (t.type == 'bonus') {
                iconData = Icons.stars_rounded;
                iconColor = AppColors.starYellow;
              } else if (t.type == 'tip') {
                iconData = Icons.volunteer_activism_rounded;
                iconColor = AppColors.success;
              } else {
                iconData = Icons.electric_moped_rounded;
                iconColor = AppColors.primary;
              }

              // Payment mode badge
              final isCod = t.paymentMode == 'cod';

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.lg,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: colors.iconContainer(color: iconColor),
                          child: Icon(iconData, color: iconColor, size: 20),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.title,
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    t.date,
                                    style: AppTextStyles.caption.copyWith(
                                      color: colors.textTertiary,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isCod
                                          ? const Color(
                                              0xFFF59E0B,
                                            ).withAlpha(20)
                                          : const Color(
                                              0xFF6366F1,
                                            ).withAlpha(20),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isCod ? "COD" : "Online",
                                      style: AppTextStyles.caption.copyWith(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: isCod
                                            ? const Color(0xFFF59E0B)
                                            : const Color(0xFF6366F1),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "${isPositive ? '+' : '-'}₹ ${t.amount.abs().toStringAsFixed(0)}",
                          style: AppTextStyles.bodyMd.copyWith(
                            color: isPositive
                                ? colors.textPrimary
                                : AppColors.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < txns.length - 1)
                    Divider(
                      color: colors.divider,
                      height: 1,
                      indent: AppSpacing.xl,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
