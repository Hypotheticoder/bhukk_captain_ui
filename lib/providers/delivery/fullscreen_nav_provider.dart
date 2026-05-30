import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks whether fullscreen navigation is active.
/// MainShell watches this to hide/show the bottom navigation bar.
class FullscreenNavNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}

final fullscreenNavProvider = NotifierProvider<FullscreenNavNotifier, bool>(
  FullscreenNavNotifier.new,
);
