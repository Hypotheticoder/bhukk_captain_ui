import 'package:bhukkdelivery/cards/cosmatics_screen/cosmatics_history_card.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CosmaticsHistoryScreen extends StatelessWidget {
  const CosmaticsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    final rides = [
      {
        'title': 'Cosmatics CS-4101',
        'date': 'Mar 15, 2026 10:05',
        'distance': '3.9 km',
        'duration': '15 min',
        'fare': '₹160',
        'status': 'Completed',
      },
      {
        'title': 'Cosmatics CS-4098',
        'date': 'Mar 14, 2026 16:40',
        'distance': '7.2 km',
        'duration': '26 min',
        'fare': '₹240',
        'status': 'Completed',
      },
      {
        'title': 'Cosmatics CS-4090',
        'date': 'Mar 13, 2026 12:18',
        'distance': '4.6 km',
        'duration': '19 min',
        'fare': '₹180',
        'status': 'Cancelled',
      },
    ];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Cosmatics History',
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
          children: [
            const SizedBox(height: AppSpacing.md),
            ...List.generate(rides.length, (i) {
              final r = rides[i];
              return Column(
                children: [
                  CosmaticsHistoryCard(ride: r),
                  if (i < rides.length - 1)
                    const SizedBox(height: AppSpacing.lg),
                ],
              );
            }),
            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
    );
  }
}
