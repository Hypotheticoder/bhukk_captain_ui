import 'dart:convert';
import 'package:bhukkdelivery/services/api/api_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Service for fetching global app settings from the backend.
class SettingsService {
  static final Dio _dio = ApiConfig.dio;

  /// Fetches a single setting value by its key.
  /// GET /settings/{key}
  static Future<String?> getSetting(String key) async {
    try {
      final response = await _dio.get('/settings/$key');
      debugPrint('[SettingsService] Key: $key, Status: ${response.statusCode}');
      debugPrint('[SettingsService] Response type: ${response.data.runtimeType}');
      
      var data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }
      
      if (response.statusCode == 200 && data != null) {
        if (data is Map) {
          final value = data['value']?.toString();
          debugPrint('[SettingsService] Parsed map value for $key: $value');
          return value;
        }
        final value = data.toString();
        debugPrint('[SettingsService] Parsed raw value for $key: $value');
        return value;
      }
      return null;
    } catch (e) {
      debugPrint('[SettingsService] Error fetching setting $key: $e');
      rethrow;
    }
  }

  /// Convenience: fetches the support phone number.
  static Future<String?> getSupportPhone() =>
      getSetting('support_phone');
}
