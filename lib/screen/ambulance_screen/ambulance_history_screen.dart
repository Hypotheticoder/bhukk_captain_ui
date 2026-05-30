import 'package:bhukkdelivery/cards/ambulance_screen/ambulance_history_card.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AmbulanceHistoryScreen extends StatelessWidget {
  const AmbulanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    // Sample history data — replace with provider when available
    final rides = [
      {
        'title': 'Trip A-1001',
        'date': 'Mar 14, 2026 10:22',
        'distance': '2.3 km',
        'duration': '8 min',
        'fare': '₹0',
        'status': 'Completed',
      },
      {
        'title': 'Trip A-0998',
        'date': 'Mar 13, 2026 18:05',
        'distance': '5.1 km',
        'duration': '15 min',
        'fare': '₹0',
        'status': 'Completed',
      },
      {
        'title': 'Trip A-0981',
        'date': 'Mar 12, 2026 09:12',
        'distance': '8.4 km',
        'duration': '22 min',
        'fare': '₹0',
        'status': 'Cancelled',
      },
    ];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Ride History',
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
                  AmbulanceHistoryCard(ride: r),
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
