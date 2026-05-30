import 'package:bhukkdelivery/cards/cosmatics_screen/cosmatics_take_order_card.dart';
import 'package:bhukkdelivery/models/cosmatics_order.dart';
import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CosmaticsTakeOrdersScreen extends ConsumerStatefulWidget {
  const CosmaticsTakeOrdersScreen({super.key});

  @override
  ConsumerState<CosmaticsTakeOrdersScreen> createState() =>
      _CosmaticsTakeOrdersScreenState();
}

class _CosmaticsTakeOrdersScreenState
    extends ConsumerState<CosmaticsTakeOrdersScreen> {
  final List<CosmaticsOrder> _orders = const [
    CosmaticsOrder(
      id: 'CS-4101',
      storeName: 'GlowMart Cosmetics',
      items: 'Lipstick, Compact, Kajal',
      itemCount: 3,
      pickupAddress: 'GlowMart, MG Road',
      dropAddress: 'Flat 7B, Orchid Residency',
      etaMinutes: 11,
      distance: '3.9 km',
      fare: 160,
      contactNumber: '+91 90000 33333',
      notes: 'Handle with care (glass bottle)',
    ),
    CosmaticsOrder(
      id: 'CS-4102',
      storeName: 'BeautyBox',
      items: 'Face wash, Sunscreen',
      itemCount: 2,
      pickupAddress: 'BeautyBox, City Center',
      dropAddress: 'No. 14, Lake View',
      etaMinutes: 19,
      distance: '7.2 km',
      fare: 240,
      contactNumber: '+91 90000 44444',
      notes: '',
    ),
  ];

  int _selected = 0;

  void _accept(CosmaticsOrder o) {
    ref
        .read(activeDeliveryProvider.notifier)
        .startDelivery(
          ActiveDelivery(
            orderId: o.id,
            storeName: o.storeName,
            customerName: 'Customer',
            items: o.items,
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

  void _decline(CosmaticsOrder o) {
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
        title: const Text('Incoming Cosmatics Requests'),
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
                      child: CosmaticsTakeOrderCard(
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
