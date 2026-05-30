import 'package:bhukkdelivery/services/api/api_config.dart';
import 'package:dio/dio.dart';

class OrdersService {
  static final Dio _dio = ApiConfig.dio;

  static Future<List<dynamic>> fetchOrderHistory({
    String serviceType = 'all',
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      // Pass the service type to our new backend route!
      final queryParam = serviceType.toLowerCase() == 'all'
          ? '?skip=$skip&limit=$limit'
          : '?service_type=${serviceType.toLowerCase()}&skip=$skip&limit=$limit';

      final response = await _dio.get('/drivers/me/jobs/history$queryParam');
      if (response.statusCode == 200 && response.data != null) {
        // Handle both direct arrays and wrapped paginated responses (e.g. {"data": [], "total": 100})
        if (response.data is List) {
          return response.data as List<dynamic>;
        } else if (response.data is Map) {
          final items = response.data['items'] ?? response.data['data'] ?? response.data['jobs'] ?? response.data['results'];
          if (items is List) return items;
        }
      }
      return [];
    } catch (e) {
      // print("Error fetching order history: $e");
      rethrow;
    }
  }
}
