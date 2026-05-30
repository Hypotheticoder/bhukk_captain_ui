import 'package:bhukkdelivery/services/api/auth_service.dart';
import 'package:bhukkdelivery/services/api/dispatch_job_service.dart';
import 'package:bhukkdelivery/services/dispatch_order_helper.dart';
import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bhukkdelivery/services/background_notification_service.dart';

// Simple state to track initialization status
enum SplashStatus { loading, authenticated, authenticatedWithActiveOrder, authenticatedWithPayment, unauthenticated }

class SplashNotifier extends Notifier<SplashStatus> {
  @override
  SplashStatus build() {
    _init();
    return SplashStatus.loading;
  }

  Future<void> _init() async {
    // Give the splash animation time to play
    await Future.delayed(const Duration(seconds: 3));

    // Check if user is already signed in via Firebase
    if (AuthService.isSignedIn) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final activeOrderId = prefs.getString('active_order_id');

        if (activeOrderId != null && activeOrderId.isNotEmpty) {
          debugPrint('[SplashNotifier] Restoring active order from local cache: $activeOrderId');
          final job = await DispatchJobService.instance.getJob(activeOrderId);
          if (job != null &&
              job.status.toLowerCase() != 'completed' &&
              job.status.toLowerCase() != 'cancelled') {
            
            final isDelivered = job.status.toLowerCase() == 'delivered';
            final pm = job.paymentMethod.trim().toLowerCase();
            final isCod = pm.contains('cod') || pm.contains('cash');
            final isUnpaid = job.paymentStatus.toLowerCase() == 'unpaid' || job.paymentStatus.toLowerCase() == 'pending';

            if (isDelivered && (!isCod || !isUnpaid)) {
              // Delivered and prepaid (or already paid COD) means we are done, clear local cache.
              await prefs.remove('active_order_id');
            } else {
              // Reconstruct ActiveDelivery and restore it to Riverpod state!
              final orderRequest = dispatchJobToOrderRequest(job);
              final activeDelivery = orderRequestToActiveDelivery(orderRequest);

              ref.read(activeDeliveryProvider.notifier).startDelivery(activeDelivery);
              
              if (isDelivered && isCod && isUnpaid) {
                state = SplashStatus.authenticatedWithPayment;
              } else {
                state = SplashStatus.authenticatedWithActiveOrder;
              }
              return;
            }
          } else {
            // Wiped from backend or completed/cancelled, clear the local cache
            await prefs.remove('active_order_id');
            await BackgroundNotificationService.instance.stopAndClear();
          }
        } else {
          // If there is no active order ID, ensure any stale notifications are cleared
          await BackgroundNotificationService.instance.stopAndClear();
        }
      } catch (e) {
        debugPrint('[SplashNotifier] Failed to restore active order startup: $e');
        await BackgroundNotificationService.instance.stopAndClear();
      }

      state = SplashStatus.authenticated;
    } else {
      state = SplashStatus.unauthenticated;
    }
  }
}
