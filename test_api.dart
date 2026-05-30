import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  try {
    final res = await dio.get('http://192.168.0.222:8000/settings/support_phone');
    print("Settings response type: ${res.data.runtimeType}");
    print("Settings data: ${res.data}");
    
    final resAds = await dio.get('http://192.168.0.222:8000/ads/carousel');
    print("Ads response type: ${resAds.data.runtimeType}");
    print("Ads data: ${resAds.data}");
  } catch(e) {
    print("Error: $e");
  }
}
