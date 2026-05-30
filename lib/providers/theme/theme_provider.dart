export 'package:bhukkdelivery/notifiers/theme/theme_notifier.dart';
import 'package:bhukkdelivery/notifiers/theme/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});
