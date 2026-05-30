export 'package:bhukkdelivery/notifiers/beverages_screen/beverages_notifier.dart';
import 'package:bhukkdelivery/notifiers/beverages_screen/beverages_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final beveragesProvider =
    NotifierProvider<BeveragesNotifier, BeveragesState>(() {
  return BeveragesNotifier();
});
