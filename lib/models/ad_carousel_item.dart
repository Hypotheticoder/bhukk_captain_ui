import 'package:bhukkdelivery/services/api/api_config.dart';

class AdCarouselItem {
  final String title;
  final String mediaType;
  final String targetUrl;
  final bool isActive;
  final int displayOrder;
  final String id;
  final String mediaUrl;
  final DateTime createdAt;

  const AdCarouselItem({
    required this.title,
    required this.mediaType,
    required this.targetUrl,
    required this.isActive,
    required this.displayOrder,
    required this.id,
    required this.mediaUrl,
    required this.createdAt,
  });

  /// Computes the absolute media URL by resolving relative URLs against the API base URL.
  String get absoluteMediaUrl {
    if (mediaUrl.isEmpty) return '';
    if (mediaUrl.startsWith('http://') || mediaUrl.startsWith('https://')) {
      return mediaUrl;
    }
    
    final baseUrl = ApiConfig.baseUrl;
    final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final cleanPath = mediaUrl.startsWith('/') ? mediaUrl : '/$mediaUrl';
    return '$cleanBase$cleanPath';
  }

  factory AdCarouselItem.fromJson(Map<String, dynamic> json) {
    return AdCarouselItem(
      title: json['title']?.toString() ?? '',
      mediaType: json['media_type']?.toString() ?? 'image',
      targetUrl: json['target_url']?.toString() ?? '',
      isActive: json['is_active'] is bool ? json['is_active'] : (json['is_active'] == 1 || json['is_active'] == 'true'),
      displayOrder: (json['display_order'] is num) ? (json['display_order'] as num).toInt() : int.tryParse(json['display_order']?.toString() ?? '') ?? 0,
      id: json['id']?.toString() ?? '',
      mediaUrl: json['media_url']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
