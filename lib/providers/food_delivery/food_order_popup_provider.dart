export 'package:bhukkdelivery/notifiers/food_delivery_screen/food_order_popup_notifier.dart';
import 'package:bhukkdelivery/notifiers/food_delivery_screen/food_order_popup_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final foodOrderPopupProvider =
    NotifierProvider.autoDispose<FoodOrderPopupNotifier, FoodOrderPopupState>(
      () {
        return FoodOrderPopupNotifier();
      },
    );
