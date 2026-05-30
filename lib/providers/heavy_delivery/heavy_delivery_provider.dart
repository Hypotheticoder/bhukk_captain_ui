export 'package:bhukkdelivery/notifiers/heavy_delivery_screen/heavy_delivery_notifier.dart';
import 'package:bhukkdelivery/notifiers/heavy_delivery_screen/heavy_delivery_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final heavyDeliveryProvider =
    NotifierProvider<HeavyDeliveryNotifier, HeavyDeliveryState>(() {
  return HeavyDeliveryNotifier();
});
