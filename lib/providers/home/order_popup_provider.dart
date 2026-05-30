export 'package:bhukkdelivery/notifiers/home_screen/order_popup_notifier.dart';
import 'package:bhukkdelivery/notifiers/home_screen/order_popup_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderPopupProvider =
    NotifierProvider<OrderPopupNotifier, OrderPopupState>(() {
      return OrderPopupNotifier();
    });
