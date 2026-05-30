import 'package:flutter_riverpod/flutter_riverpod.dart';

class RiderStatusNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false; // Initial state: Offline
  }

  void toggle() {
    state = !state;
  }
}
