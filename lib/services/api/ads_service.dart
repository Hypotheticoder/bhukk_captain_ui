import 'dart:convert';
import 'package:bhukkdelivery/models/ad_carousel_item.dart';
import 'package:bhukkdelivery/services/api/api_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AdsService {
  static final Dio _dio = ApiConfig.dio;

  /// Fetches advertisements for the carousel.
  /// GET /ads/carousel
  static Future<List<AdCarouselItem>> getCarouselAds() async {
    try {
      final response = await _dio.get('/ads/carousel');
      debugPrint('[AdsService] Status: ${response.statusCode}');
      debugPrint('[AdsService] Response type: ${response.data.runtimeType}');
      
      var data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }
      
      if (response.statusCode == 200 && data is List) {
        final ads = (data as List)
            .map((e) => AdCarouselItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        debugPrint('[AdsService] Parsed ${ads.length} ads.');
        return ads;
      }
      return [];
    } catch (e) {
      debugPrint('[AdsService] Error fetching ads: $e');
      rethrow;
    }
  }
}
