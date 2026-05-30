export 'package:bhukkdelivery/notifiers/new_order_request_screen/parcel_order_notifier.dart';
export 'package:bhukkdelivery/models/order_request.dart' show NewOrdersState;
import 'package:bhukkdelivery/models/order_request.dart';
import 'package:bhukkdelivery/notifiers/new_order_request_screen/parcel_order_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for parcel-specific order popup state.
/// Separate from cab orders to prevent cross-contamination.
final parcelOrderProvider =
    NotifierProvider<ParcelOrderNotifier, NewOrdersState>(() {
      return ParcelOrderNotifier();
    });
