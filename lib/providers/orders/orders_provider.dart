export 'package:bhukkdelivery/notifiers/orders_screen/orders_notifier.dart';
export 'package:bhukkdelivery/notifiers/orders_screen/live_jobs_notifier.dart';
export 'package:bhukkdelivery/providers/orders/live_jobs_provider.dart';

import 'package:bhukkdelivery/notifiers/orders_screen/orders_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ordersProvider =
    NotifierProvider<OrdersNotifier, OrdersState>(() {
  return OrdersNotifier();
});
