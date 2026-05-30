import 'package:bhukkdelivery/cards/cosmatics_screen/cosmatics_earnings_card.dart';
import 'package:bhukkdelivery/cards/earning_details_screen/summary_chart_card.dart';
import 'package:bhukkdelivery/cards/earning_details_screen/transaction_history_card.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CosmaticsEarningsScreen extends StatelessWidget {
  const CosmaticsEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Cosmatics Earnings',
          style: AppTextStyles.headingMd.copyWith(color: colors.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: AppSpacing.lg,
          bottom: 120,
        ),
        child: Column(
          children: const [
            CosmaticsEarningsCard(),
            SizedBox(height: AppSpacing.xxl),
            SummaryChartCard(),
            SizedBox(height: AppSpacing.xxl),
            TransactionHistoryCard(),
            SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
    );
  }
}
