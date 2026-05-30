export 'package:bhukkdelivery/notifiers/cosmatics_screen/cosmatics_order_popup_notifier.dart';
import 'package:bhukkdelivery/notifiers/cosmatics_screen/cosmatics_order_popup_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cosmaticsOrderPopupProvider =
    NotifierProvider.autoDispose<
      CosmaticsOrderPopupNotifier,
      CosmaticsOrderPopupState
    >(() {
      return CosmaticsOrderPopupNotifier();
    });
