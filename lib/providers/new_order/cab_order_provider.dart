export 'package:bhukkdelivery/notifiers/new_order_request_screen/cab_order_notifier.dart';
export 'package:bhukkdelivery/models/order_request.dart' show NewOrdersState;
import 'package:bhukkdelivery/models/order_request.dart';
import 'package:bhukkdelivery/notifiers/new_order_request_screen/cab_order_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for cab/ride-specific order popup state.
/// Separate from parcel orders to prevent cross-contamination.
final cabOrderProvider = NotifierProvider<CabOrderNotifier, NewOrdersState>(() {
  return CabOrderNotifier();
});
