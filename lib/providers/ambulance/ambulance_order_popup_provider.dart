export 'package:bhukkdelivery/notifiers/ambulance_screen/ambulance_order_popup_notifier.dart';
import 'package:bhukkdelivery/notifiers/ambulance_screen/ambulance_order_popup_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ambulanceOrderPopupProvider =
    NotifierProvider.autoDispose<
      AmbulanceOrderPopupNotifier,
      AmbulanceOrderPopupState
    >(() {
      return AmbulanceOrderPopupNotifier();
    });
