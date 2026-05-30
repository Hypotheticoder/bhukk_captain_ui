import 'package:bhukkdelivery/providers/earnings/earnings_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionHistoryCard extends ConsumerWidget {
  const TransactionHistoryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = C.of(context);
    final txns = ref.watch(earningsProvider.select((s) => s.transactions));

    if (txns.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: colors.card,
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 48,
              color: colors.textTertiary.withAlpha(100),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              "No transactions yet",
              style: AppTextStyles.bodyMd.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              "Complete orders to see your transaction history",
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Transactions",
                  style: AppTextStyles.headingSm.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  "${txns.length} entries",
                  style: AppTextStyles.caption.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: colors.divider, height: 1),
          ...List.generate(txns.length, (index) {
            final t = txns[index];
            final isPositive = t.type != 'fee';
            final isCod = t.paymentMode == 'cod';

            IconData iconData;
            Color iconColor;
            if (t.type == 'payout') {
              iconData = isCod
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
                                        ? const Color(0xFFF59E0B).withAlpha(20)
                                        : const Color(0xFF6366F1).withAlpha(20),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
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
                    ],
                  ),
                ),
                if (index < txns.length - 1)
                  Divider(
                      color: colors.divider,
                      height: 1,
                      indent: AppSpacing.xl),
              ],
            );
          }),
        ],
      ),
    );
  }
}
