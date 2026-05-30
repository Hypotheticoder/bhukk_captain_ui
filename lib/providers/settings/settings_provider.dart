import 'package:bhukkdelivery/services/api/settings_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider that fetches the support phone number from the backend.
/// Auto-disposes when no longer being watched.
final supportPhoneProvider = FutureProvider.autoDispose<String?>((ref) async {
  return SettingsService.getSupportPhone();
});
