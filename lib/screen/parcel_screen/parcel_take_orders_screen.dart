import 'dart:async';

import 'package:bhukkdelivery/models/order_request.dart';
import 'package:bhukkdelivery/services/api/dispatch_job_service.dart';
import 'package:bhukkdelivery/services/dispatch_order_helper.dart';
import 'package:bhukkdelivery/services/location_service.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bhukkdelivery/cards/parcel_screen/parcel_take_order_card.dart';
import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:go_router/go_router.dart';

class ParcelTakeOrdersScreen extends ConsumerStatefulWidget {
  const ParcelTakeOrdersScreen({super.key});

  @override
  ConsumerState<ParcelTakeOrdersScreen> createState() =>
      _ParcelTakeOrdersScreenState();
}

class _ParcelTakeOrdersScreenState
    extends ConsumerState<ParcelTakeOrdersScreen> {
  final _service = DispatchJobService.instance;
  List<OrderRequest> _orders = [];
  bool _isLoading = true;
  String? _error;
  int _selected = 0;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    // Auto refresh every 15s
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _fetchOrders();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    try {
      // Get the driver's current location for radius-based filtering
      double? driverLat;
      double? driverLng;
      try {
        final loc = await LocationService.instance.getCurrentPosition();
        if (loc != null) {
          driverLat = loc.latitude;
          driverLng = loc.longitude;
        }
      } catch (_) {
        // Location unavailable — backend will skip radius filter
      }

      final jobs = await _service.listJobs(
        driverLat: driverLat,
        driverLng: driverLng,
        acceptsParcels: true,
        acceptsRides: false,
        limit: 20,
      );
      if (mounted) {
        setState(() {
          _orders = jobs
              .where((j) => j.status.toUpperCase() == 'PENDING')
              .map(
                (j) => dispatchJobToOrderRequest(
                  j,
                  cuisineOverride: 'Parcel',
                  itemsOverride: 'Parcel delivery',
                ),
              )
              .toList();
          _isLoading = false;
          _error = null;
          if (_selected >= _orders.length) {
            _selected = 0;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (_orders.isEmpty) {
            _error = "Failed to load orders\n$e";
          }
        });
      }
    }
  }

  Future<void> _accept(OrderRequest o) async {
    try {
      await _service.acceptJob(o.orderId, driverId: 'current_driver');
      if (mounted) {
        ref
            .read(activeDeliveryProvider.notifier)
            .startDelivery(
              orderRequestToActiveDelivery(o, serviceTypeOverride: 'Parcel'),
            );
        context.push('/home/live_navigation');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to accept order: $e')));
        _fetchOrders(); // Refresh list to see if another driver took it
      }
    }
  }

  void _decline(OrderRequest o) {
    _service.rejectJob(o.orderId);
    setState(() {
      _orders.remove(o);
      if (_selected >= _orders.length) {
        _selected = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Incoming Parcel Requests'),
        leading: BackButton(color: colors.textPrimary),
        backgroundColor: colors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colors.textPrimary),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchOrders();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nearby parcels',
                style: AppTextStyles.overline.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              if (_isLoading && _orders.isEmpty)
                Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (_error != null && _orders.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ),
                )
              else if (_orders.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      "No incoming parcel orders",
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ),
                )
              else ...[
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
                        child: ParcelTakeOrderCard(
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
            ],
          ),
        ),
      ),
    );
  }
}
