import 'package:bhukkdelivery/services/api/api_config.dart';
import 'package:dio/dio.dart';

class EarningsService {
  static final Dio _dio = ApiConfig.dio;

  /// Fetches everything needed for the Earnings Dashboard in parallel
  /// Can be filtered by serviceType (e.g., 'all', 'ride', 'parcel')
  static Future<Map<String, dynamic>> getFullEarningsDashboard({
    String serviceType = 'all',
  }) async {
    try {
      // 🚨 Append the query parameter based on the selected chip!
      final queryParam = serviceType.toLowerCase() == 'all'
          ? ''
          : '?service_type=${serviceType.toLowerCase()}';

      // Fire all 3 API calls at the exact same time
      final responses = await Future.wait([
        _dio.get('/drivers/me/earnings$queryParam'), // 0: Balances & Buckets
        _dio.get(
          '/drivers/me/wallet/statement$queryParam',
        ), // 1: Transaction List
        _dio.get('/drivers/me/wallet/analytics$queryParam'), // 2: Chart Data
      ]);

      return {
        'balances': responses[0].data,
        'statement': responses[1].data,
        'analytics': responses[2].data,
      };
    } catch (e) {
      // print("[EarningsService] API Error: $e");
      rethrow;
    }
  }

  /// Fetches earning configuration (pricing, GST breakdown) for the driver's vehicle type.
  /// GET /drivers/me/earning-config?vehicle_type=bike
  static Future<Map<String, dynamic>> getEarningConfig({
    required String vehicleType,
  }) async {
    try {
      final response = await _dio.get(
        '/drivers/me/earning-config',
        queryParameters: {'vehicle_type': vehicleType},
      );
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      return {};
    } on DioException {
      return {};
    }
  }

  /// Legacy method kept for backward compatibility
  static Future<Map<String, dynamic>> getEarnings() async {
    final data = await getFullEarningsDashboard();
    return Map<String, dynamic>.from(data['balances']);
  }
}
