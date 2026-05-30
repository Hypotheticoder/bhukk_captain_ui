export 'package:bhukkdelivery/notifiers/earnings_screen/earnings_notifier.dart';
import 'package:bhukkdelivery/notifiers/earnings_screen/earnings_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final earningsProvider =
    NotifierProvider<EarningsNotifier, EarningsState>(() {
  return EarningsNotifier();
});
