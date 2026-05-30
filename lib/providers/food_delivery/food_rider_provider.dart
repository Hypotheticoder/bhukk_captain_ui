export 'package:bhukkdelivery/notifiers/food_delivery_screen/food_rider_status_notifier.dart';
import 'package:bhukkdelivery/notifiers/food_delivery_screen/food_rider_status_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final foodRiderStatusProvider =
    NotifierProvider<FoodRiderStatusNotifier, bool>(() {
      return FoodRiderStatusNotifier();
    });
