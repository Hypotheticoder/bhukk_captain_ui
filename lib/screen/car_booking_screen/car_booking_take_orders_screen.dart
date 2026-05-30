import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bhukkdelivery/models/cab_order.dart';
import 'package:bhukkdelivery/cards/car_booking_screen/cab_take_order_card.dart';
import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CarBookingTakeOrdersScreen extends ConsumerStatefulWidget {
  const CarBookingTakeOrdersScreen({super.key});

  @override
  ConsumerState<CarBookingTakeOrdersScreen> createState() =>
      _CarBookingTakeOrdersScreenState();
}

class _CarBookingTakeOrdersScreenState
    extends ConsumerState<CarBookingTakeOrdersScreen> {
  final List<CabOrder> _orders = const [
    CabOrder(
      id: 'C-3001',
      passengerName: 'Vikram Singh',
      pickupAddress: 'Near City Square',
      dropAddress: 'Hillview Apartments',
      etaMinutes: 6,
      distance: '2.1 km',
      fare: 90,
      contactNumber: '+91 90012 34567',
    ),
    CabOrder(
      id: 'C-3002',
      passengerName: 'Neha Rao',
      pickupAddress: 'Green Park',
      dropAddress: 'Sunset Boulevard',
      etaMinutes: 14,
      distance: '5.6 km',
      fare: 160,
      contactNumber: '+91 90098 76543',
    ),
  ];

  int _selected = 0;

  void _accept(CabOrder o) {
    ref
        .read(activeDeliveryProvider.notifier)
        .startDelivery(
          ActiveDelivery(
            orderId: o.id,
            storeName: o.passengerName,
            customerName: o.passengerName,
            items: 'Cab Ride',
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

  void _decline(CabOrder o) {
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
        title: const Text('Incoming Cab Requests'),
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
                'Nearby rides',
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
                      child: CabTakeOrderCard(
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
