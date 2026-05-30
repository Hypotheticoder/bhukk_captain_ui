import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bhukkdelivery/notifiers/payment_screen/payment_notifier.dart';

final paymentProvider =
    NotifierProvider<PaymentNotifier, PaymentState>(() {
  return PaymentNotifier();
});
