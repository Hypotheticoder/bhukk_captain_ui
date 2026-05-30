export 'package:bhukkdelivery/notifiers/cosmatics_screen/cosmatics_rider_status_notifier.dart';
import 'package:bhukkdelivery/notifiers/cosmatics_screen/cosmatics_rider_status_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cosmaticsRiderStatusProvider =
    NotifierProvider<CosmaticsRiderStatusNotifier, bool>(() {
      return CosmaticsRiderStatusNotifier();
    });
