export 'package:bhukkdelivery/notifiers/profile_screen/profile_notifier.dart';
import 'package:bhukkdelivery/notifiers/profile_screen/profile_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileProvider = NotifierProvider<ProfileNotifier, UserProfile?>(() {
  return ProfileNotifier();
});
