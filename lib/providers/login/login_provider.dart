import 'package:bhukkdelivery/notifiers/login_screen/login_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginProvider = NotifierProvider<LoginNotifier, LoginState>(
  () => LoginNotifier(),
);
