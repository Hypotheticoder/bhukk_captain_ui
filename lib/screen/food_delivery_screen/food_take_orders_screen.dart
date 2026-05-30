import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bhukkdelivery/models/food_order.dart';
import 'package:bhukkdelivery/cards/food_delivery_screen/food_take_order_card.dart';
import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FoodTakeOrdersScreen extends ConsumerStatefulWidget {
  const FoodTakeOrdersScreen({super.key});

  @override
  ConsumerState<FoodTakeOrdersScreen> createState() =>
      _FoodTakeOrdersScreenState();
}

class _FoodTakeOrdersScreenState extends ConsumerState<FoodTakeOrdersScreen> {
  final List<FoodOrder> _orders = const [
    FoodOrder(
      id: 'F-1001',
      restaurantName: 'Spice & Grill',
      items: ['Paneer Wrap', 'Masala Fries'],
      totalItems: 2,
      pickupAddress: 'Spice & Grill, MG Road',
      dropAddress: 'Flat 12, Rose Apartments',
      etaMinutes: 12,
      distance: '4.2 km',
      fare: 180,
      contactNumber: '+91 90000 11111',
    ),
    FoodOrder(
      id: 'F-1002',
      restaurantName: 'Ocean Bites',
      items: ['Fish Curry', 'Steamed Rice'],
      totalItems: 2,
      pickupAddress: 'Ocean Bites, Harbor Lane',
      dropAddress: 'No. 9, Sea View',
      etaMinutes: 20,
      distance: '8.1 km',
      fare: 240,
      contactNumber: '+91 90000 22222',
    ),
  ];

  int _selected = 0;

  void _accept(FoodOrder o) {
    ref
        .read(activeDeliveryProvider.notifier)
        .startDelivery(
          ActiveDelivery(
            orderId: o.id,
            storeName: o.restaurantName,
            customerName: 'Customer',
            items: o.items.join(', '),
            earnings: o.fare,
            distance: o.distance,
            pickupLocation: const LatLng(22.4853, 88.3693),
            dropoffLocation: const LatLng(22.5726, 88.3639),
            status: DeliveryStatus.headingToStore,
            storeAddress: o.pickupAddress,
            customerAddress: o.dropAddress,
          ),
        );
    context.push('/home/live_navigation');
  }

  void _decline(FoodOrder o) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Declined ${o.id}')));
    setState(() => _selected = (_selected + 1) % _orders.length);
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Incoming Food Requests'),
        leading: BackButton(color: colors.textPrimary),
        backgroundColor: colors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nearby orders',
                style: AppTextStyles.overline.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              Expanded(
                child: ListView.separated(
                  itemCount: _orders.length,
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (c, i) =>
                      const SizedBox(height: AppSpacing.lg),
                  itemBuilder: (c, i) {
                    final o = _orders[i];
                    return GestureDetector(
                      onTap: () => setState(() => _selected = i),
                      child: FoodTakeOrderCard(
                        order: o,
                        onAccept: () => _accept(o),
                        onDecline: () => _decline(o),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_orders.length, (i) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm / 2,
                    ),
                    width: _selected == i ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _selected == i
                          ? AppColors.primary
                          : colors.textSecondary.withAlpha(60),
                      borderRadius: AppRadius.xxlAll,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
