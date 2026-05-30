export 'package:bhukkdelivery/notifiers/ambulance_screen/ambulance_notifier.dart';
import 'package:bhukkdelivery/notifiers/ambulance_screen/ambulance_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ambulanceProvider =
    NotifierProvider<AmbulanceNotifier, AmbulanceState>(() {
  return AmbulanceNotifier();
});
