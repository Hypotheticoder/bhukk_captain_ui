import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bhukkdelivery/models/ambulance_order.dart';
import 'package:bhukkdelivery/cards/ambulance_screen/take_order_card.dart';
import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TakeOrderScreen extends ConsumerStatefulWidget {
  const TakeOrderScreen({super.key});

  @override
  ConsumerState<TakeOrderScreen> createState() => _TakeOrderScreenState();
}

class _TakeOrderScreenState extends ConsumerState<TakeOrderScreen> {
  // Sample orders for UI — replace with provider-backed data when available
  final List<AmbulanceOrder> _orders = const [
    AmbulanceOrder(
      id: 'A-1001',
      patientName: 'Ravi Kumar',
      pickupAddress: '12B MG Road, Sector 5',
      dropAddress: 'City Hospital, Emergency',
      severity: 'Critical',
      etaMinutes: 4,
      distance: '2.3 km',
      fare: 0,
      contactNumber: '+91 98765 43210',
      notes: 'Unconscious; breathing shallow',
    ),
    AmbulanceOrder(
      id: 'A-1002',
      patientName: 'Sunita Sharma',
      pickupAddress: 'Block C, Green Apartments',
      dropAddress: 'St. Marys General',
      severity: 'High',
      etaMinutes: 8,
      distance: '5.1 km',
      fare: 0,
      contactNumber: '+91 91234 56789',
      notes: 'Chest pain; conscious',
    ),
  ];

  int _selected = 0;

  void _acceptOrder(AmbulanceOrder order) {
    ref
        .read(activeDeliveryProvider.notifier)
        .startDelivery(
          ActiveDelivery(
            orderId: order.id,
            storeName: order.patientName,
            customerName: 'Hospital',
            items: 'Emergency Ride',
            earnings: order.fare,
            distance: order.distance,
            pickupLocation: const LatLng(22.4853, 88.3693),
            dropoffLocation: const LatLng(22.5726, 88.3639),
            status: DeliveryStatus.headingToStore,
            storeAddress: order.pickupAddress,
            customerAddress: order.dropAddress,
          ),
        );
    context.push('/home/live_navigation');
  }

  void _declineOrder(AmbulanceOrder order) {
    // simple UI response for now
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Declined ${order.id}')));
    setState(() {
      _selected = (_selected + 1) % _orders.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    // selected order is tracked by `_selected` and used by the indicator below

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Incoming Ambulance Requests'),
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
                'Nearby request',
                style: AppTextStyles.overline.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              Expanded(
                child: ListView.separated(
                  itemCount: _orders.length,
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.lg),
                  itemBuilder: (context, index) {
                    final o = _orders[index];
                    return GestureDetector(
                      onTap: () => setState(() => _selected = index),
                      child: TakeOrderCard(
                        order: o,
                        onAccept: () => _acceptOrder(o),
                        onDecline: () => _declineOrder(o),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // simple pager indicator
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
