export 'package:bhukkdelivery/notifiers/car_booking_screen/car_booking_notifier.dart';
import 'package:bhukkdelivery/notifiers/car_booking_screen/car_booking_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final carBookingProvider =
    NotifierProvider<CarBookingNotifier, CarBookingState>(() {
  return CarBookingNotifier();
});
