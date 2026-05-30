import 'package:bhukkdelivery/cards/earning_screen/settle_bottom_sheet.dart';
import 'package:bhukkdelivery/cards/earning_screen/withdraw_bottom_sheet.dart';
import 'package:bhukkdelivery/providers/earnings/earnings_provider.dart';
import 'package:bhukkdelivery/providers/profile/profile_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EarningsTotalCard extends ConsumerWidget {
  const EarningsTotalCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(earningsProvider);

    final netBalance = state.netBalance;
    final isOwing = netBalance < 0;

    final bgColor = isOwing ? AppColors.error : AppColors.primary;
    final titleText = isOwing ? "YOU OWE COMPANY" : "AVAILABLE TO WITHDRAW";
    final buttonText = isOwing ? "Settle Up" : "Withdraw";
    final buttonIcon =
        isOwing ? Icons.payment_rounded : Icons.account_balance_wallet_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bgColor,
            bgColor.withAlpha(180),
          ],
        ),
        borderRadius: AppRadius.xxlAll,
        boxShadow: [
          BoxShadow(
            color: bgColor.withAlpha(60),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Title ──
          Text(
            titleText,
            style: AppTextStyles.overline.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Amount ──
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "₹ ${_formatAmount(netBalance.abs())}",
              style: AppTextStyles.headingXl.copyWith(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Quick stats row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _miniStat(
                Icons.money_rounded,
                "Cash: ₹${state.cashInHand.toStringAsFixed(0)}",
              ),
              Container(
                width: 1,
                height: 14,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                color: Colors.white24,
              ),
              _miniStat(
                Icons.receipt_long_rounded,
                "Commission: ₹${state.commissionOwed.toStringAsFixed(0)}",
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Action Button ──
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: bgColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.pillAll,
                ),
              ),
              onPressed: () {
                final profile = ref.read(profileProvider);
                if (isOwing) {
                  SettleBottomSheet.show(
                    context,
                    amountOwed: netBalance.abs(),
                    cashInHand: state.cashInHand,
                    commissionOwed: state.commissionOwed,
                    todayEarnings: state.todayEarnings,
                    rideEarnings: state.rideEarnings,
                    parcelEarnings: state.parcelEarnings,
                    codEarnings: state.codEarnings,
                    onlineEarnings: state.onlineEarnings,
                    driverPhone: profile?.phone ?? '',
                    driverEmail: profile?.email ?? '',
                  );
                } else {
                  WithdrawBottomSheet.show(context, netBalance,
                      profile: profile);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(buttonIcon, size: 20, color: bgColor),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    buttonText,
                    style: AppTextStyles.bodyLg.copyWith(
                      fontWeight: FontWeight.w700,
                      color: bgColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.white60),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.overline.copyWith(
            color: Colors.white60,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatAmount(double val) {
    if (val >= 1000) {
      final k = val / 1000;
      final remainder = val % 1000;
      if (remainder == 0) return "${k.toStringAsFixed(0)},000";
      return "${k.floor()},${remainder.toStringAsFixed(0).padLeft(3, '0')}";
    }
    return val.toStringAsFixed(0);
  }
}
