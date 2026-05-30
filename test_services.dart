import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'lib/services/api/settings_service.dart';
import 'lib/services/api/ads_service.dart';
import 'lib/models/ad_carousel_item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    print("Testing SettingsService...");
    final phone = await SettingsService.getSupportPhone();
    print("Phone: $phone");
  } catch (e, stack) {
    print("Settings Error: $e\n$stack");
  }

  try {
    print("Testing AdsService...");
    final ads = await AdsService.getCarouselAds();
    print("Ads: ${ads.length}");
  } catch (e, stack) {
    print("Ads Error: $e\n$stack");
  }
}
