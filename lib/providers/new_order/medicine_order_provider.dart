export 'package:bhukkdelivery/notifiers/new_order_request_screen/medicine_order_notifier.dart';
export 'package:bhukkdelivery/models/order_request.dart' show NewOrdersState;
import 'package:bhukkdelivery/models/order_request.dart';
import 'package:bhukkdelivery/notifiers/new_order_request_screen/medicine_order_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for medicine-specific order popup state.
final medicineOrderProvider =
    NotifierProvider<MedicineOrderNotifier, NewOrdersState>(() {
      return MedicineOrderNotifier();
    });
