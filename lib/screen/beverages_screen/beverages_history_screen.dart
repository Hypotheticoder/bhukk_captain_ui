import 'package:bhukkdelivery/cards/beverages_screen/beverages_history_card.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BeveragesHistoryScreen extends StatelessWidget {
  const BeveragesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    final rides = [
      {
        'title': 'Beverages BEV-6001',
        'date': 'Mar 18, 2026 09:15',
        'distance': '4.1 km',
        'duration': '18 min',
        'fare': '₹450',
        'status': 'Completed',
      },
      {
        'title': 'Beverages BEV-6002',
        'date': 'Mar 18, 2026 08:40',
        'distance': '6.8 km',
        'duration': '20 min',
        'fare': '₹890',
        'status': 'In Progress',
      },
      {
        'title': 'Beverages BEV-5998',
        'date': 'Mar 17, 2026 17:20',
        'distance': '3.2 km',
        'duration': '14 min',
        'fare': '₹320',
        'status': 'Completed',
      },
      {
        'title': 'Beverages BEV-5995',
        'date': 'Mar 17, 2026 14:05',
        'distance': '5.5 km',
        'duration': '22 min',
        'fare': '₹580',
        'status': 'Cancelled',
      },
      {
        'title': 'Beverages BEV-5990',
        'date': 'Mar 16, 2026 19:30',
        'distance': '2.8 km',
        'duration': '12 min',
        'fare': '₹240',
        'status': 'Completed',
      },
    ];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Beverages History',
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
                  BeveragesHistoryCard(ride: r),
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
