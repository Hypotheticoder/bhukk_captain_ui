export 'package:bhukkdelivery/notifiers/parcel_screen/parcel_rider_status_notifier.dart';
import 'package:bhukkdelivery/notifiers/parcel_screen/parcel_rider_status_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final parcelRiderStatusProvider =
    NotifierProvider<ParcelRiderStatusNotifier, bool>(() {
      return ParcelRiderStatusNotifier();
    });
