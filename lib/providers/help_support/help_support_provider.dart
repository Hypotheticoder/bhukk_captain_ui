export 'package:bhukkdelivery/notifiers/help_support_screen/help_support_notifier.dart';
import 'package:bhukkdelivery/notifiers/help_support_screen/help_support_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final helpSupportProvider =
    NotifierProvider<HelpSupportNotifier, HelpSupportState>(() {
  return HelpSupportNotifier();
});
