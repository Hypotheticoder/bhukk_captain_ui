export 'package:bhukkdelivery/models/order_request.dart';
export 'package:bhukkdelivery/notifiers/new_order_request_screen/new_order_notifier.dart';
import 'package:bhukkdelivery/models/order_request.dart';
import 'package:bhukkdelivery/notifiers/new_order_request_screen/new_order_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final newOrderProvider = NotifierProvider<NewOrderNotifier, NewOrdersState>(() {
  return NewOrderNotifier();
});
