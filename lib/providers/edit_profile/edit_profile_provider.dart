export 'package:bhukkdelivery/notifiers/edit_profile_screen/edit_profile_notifier.dart';
import 'package:bhukkdelivery/notifiers/edit_profile_screen/edit_profile_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final editProfileProvider =
    NotifierProvider<EditProfileNotifier, EditProfileState>(() {
  return EditProfileNotifier();
});
