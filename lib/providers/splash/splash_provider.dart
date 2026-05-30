export 'package:bhukkdelivery/notifiers/splash_screen/splash_notifier.dart';
import 'package:bhukkdelivery/notifiers/splash_screen/splash_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final splashProvider = NotifierProvider<SplashNotifier, SplashStatus>(() {
  return SplashNotifier();
});
