export 'package:bhukkdelivery/notifiers/parcel_screen/parcel_order_popup_notifier.dart';
import 'package:bhukkdelivery/notifiers/parcel_screen/parcel_order_popup_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final parcelOrderPopupProvider =
    NotifierProvider.autoDispose<
      ParcelOrderPopupNotifier,
      ParcelOrderPopupState
    >(() {
      return ParcelOrderPopupNotifier();
    });
