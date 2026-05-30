import 'package:bhukkdelivery/notifiers/register_screen/register_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final registerProvider = NotifierProvider<RegisterNotifier, RegisterState>(
  () => RegisterNotifier(),
);
