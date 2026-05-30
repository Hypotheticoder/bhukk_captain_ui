export 'package:bhukkdelivery/notifiers/food_delivery_screen/food_delivery_notifier.dart';
import 'package:bhukkdelivery/notifiers/food_delivery_screen/food_delivery_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final foodDeliveryProvider =
    NotifierProvider<FoodDeliveryNotifier, FoodDeliveryState>(() {
  return FoodDeliveryNotifier();
});
