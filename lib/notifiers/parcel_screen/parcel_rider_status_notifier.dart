import 'package:flutter_riverpod/flutter_riverpod.dart';

class ParcelRiderStatusNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void clearJob() {
    state = false;
  }

  void set(bool val) {
    state = val;
  }
}
