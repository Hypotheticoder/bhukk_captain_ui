export 'package:bhukkdelivery/notifiers/home_screen/rider_notifier.dart';
import 'package:bhukkdelivery/notifiers/home_screen/rider_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final riderStatusProvider = NotifierProvider<RiderStatusNotifier, bool>(() {
  return RiderStatusNotifier();
});
