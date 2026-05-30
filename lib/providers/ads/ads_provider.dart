import 'package:bhukkdelivery/models/ad_carousel_item.dart';
import 'package:bhukkdelivery/services/api/ads_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A provider that fetches the dynamic ads from the backend and filters out
/// any inactive ads, sorting them by display order.
final adsCarouselProvider = FutureProvider.autoDispose<List<AdCarouselItem>>((ref) async {
  final ads = await AdsService.getCarouselAds();
  // Filter active ads and sort by display order
  final activeAds = ads.where((ad) => ad.isActive).toList();
  activeAds.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  return activeAds;
});
