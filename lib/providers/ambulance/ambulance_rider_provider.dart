export 'package:bhukkdelivery/notifiers/ambulance_screen/ambulance_rider_status_notifier.dart';
import 'package:bhukkdelivery/notifiers/ambulance_screen/ambulance_rider_status_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ambulanceRiderStatusProvider =
    NotifierProvider<AmbulanceRiderStatusNotifier, bool>(() {
      return AmbulanceRiderStatusNotifier();
    });
