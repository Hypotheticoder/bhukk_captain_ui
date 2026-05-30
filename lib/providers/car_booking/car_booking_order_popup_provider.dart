export 'package:bhukkdelivery/notifiers/car_booking_screen/car_booking_order_popup_notifier.dart';
import 'package:bhukkdelivery/notifiers/car_booking_screen/car_booking_order_popup_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final carBookingOrderPopupProvider =
    NotifierProvider.autoDispose<
      CarBookingOrderPopupNotifier,
      CarBookingOrderPopupState
    >(() {
      return CarBookingOrderPopupNotifier();
    });
