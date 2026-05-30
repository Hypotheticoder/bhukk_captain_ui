import 'package:bhukkdelivery/notifiers/otp_screen/otp_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final otpProvider = NotifierProvider.autoDispose<OtpNotifier, OtpState>(
  () => OtpNotifier(),
);
