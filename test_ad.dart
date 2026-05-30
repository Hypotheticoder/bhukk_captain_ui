import 'lib/models/ad_carousel_item.dart';

void main() {
  final json = {
    "title": "string",
    "media_type": "image",
    "target_url": "string",
    "is_active": true,
    "display_order": 0,
    "id": "string",
    "media_url": "string",
    "created_at": "2026-05-26T07:45:11.944Z"
  };
  final item = AdCarouselItem.fromJson(json);
  print(item.title);
}
