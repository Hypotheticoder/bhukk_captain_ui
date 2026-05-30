import 'package:flutter_riverpod/flutter_riverpod.dart';

class CosmaticsRiderStatusNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
  }
}
