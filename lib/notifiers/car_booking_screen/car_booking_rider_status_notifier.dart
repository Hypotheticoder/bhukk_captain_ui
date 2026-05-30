import 'package:flutter_riverpod/flutter_riverpod.dart';

class CarBookingRiderStatusNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
  }
}
