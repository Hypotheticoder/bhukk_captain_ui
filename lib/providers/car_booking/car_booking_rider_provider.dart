export 'package:bhukkdelivery/notifiers/car_booking_screen/car_booking_rider_status_notifier.dart';
import 'package:bhukkdelivery/notifiers/car_booking_screen/car_booking_rider_status_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final carBookingRiderStatusProvider =
    NotifierProvider<CarBookingRiderStatusNotifier, bool>(() {
      return CarBookingRiderStatusNotifier();
    });
