import 'package:bhukkdelivery/cards/food_delivery_screen/food_history_card.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';

class FoodHistoryScreen extends StatelessWidget {
  const FoodHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    // Simple placeholder list for history — can be replaced with provider data
    final rides = [
      {
        'title': 'Food F-1000',
        'date': 'Mar 15, 2026 09:20',
        'distance': '3.4 km',
        'duration': '12 min',
        'fare': '₹150',
        'status': 'Completed',
      },
      {
        'title': 'Food F-0999',
        'date': 'Mar 14, 2026 14:10',
        'distance': '7.8 km',
        'duration': '24 min',
        'fare': '₹0',
        'status': 'Cancelled',
      },
      {
        'title': 'Food F-0988',
        'date': 'Mar 13, 2026 11:03',
        'distance': '5.2 km',
        'duration': '18 min',
        'fare': '₹220',
        'status': 'Completed',
      },
    ];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Order History'),
        leading: BackButton(color: colors.textPrimary),
        backgroundColor: colors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              ...List.generate(rides.length, (i) {
                final r = rides[i];
                return Column(
                  children: [
                    FoodHistoryCard(order: r),
                    if (i < rides.length - 1)
                      const SizedBox(height: AppSpacing.lg),
                  ],
                );
              }),
              const SizedBox(height: AppSpacing.huge),
            ],
          ),
        ),
      ),
    );
  }
}
