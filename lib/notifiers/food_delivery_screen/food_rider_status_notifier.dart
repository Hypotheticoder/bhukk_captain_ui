import 'package:flutter_riverpod/flutter_riverpod.dart';

class FoodRiderStatusNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
  }
}
