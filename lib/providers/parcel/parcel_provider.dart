export 'package:bhukkdelivery/notifiers/parcel_screen/parcel_notifier.dart';
import 'package:bhukkdelivery/notifiers/parcel_screen/parcel_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final parcelProvider = NotifierProvider<ParcelNotifier, ParcelState>(() {
  return ParcelNotifier();
});
