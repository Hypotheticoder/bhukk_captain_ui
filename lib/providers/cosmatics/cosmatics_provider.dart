export 'package:bhukkdelivery/notifiers/cosmatics_screen/cosmatics_notifier.dart';
import 'package:bhukkdelivery/notifiers/cosmatics_screen/cosmatics_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cosmaticsProvider = NotifierProvider<CosmaticsNotifier, CosmaticsState>(
  () {
    return CosmaticsNotifier();
  },
);
