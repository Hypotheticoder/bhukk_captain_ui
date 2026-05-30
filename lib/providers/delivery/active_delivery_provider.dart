export 'package:bhukkdelivery/models/active_delivery.dart';
import 'package:bhukkdelivery/models/active_delivery.dart';
import 'package:bhukkdelivery/notifiers/active_delivery_screen/active_delivery_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final activeDeliveryProvider =
    NotifierProvider<ActiveDeliveryNotifier, ActiveDelivery?>(() {
      return ActiveDeliveryNotifier();
    });
