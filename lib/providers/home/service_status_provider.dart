import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServiceStatusNotifier extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() {
    return {
      'parcel': false,
      'car_booking': false,
    };
  }

  void setOnline(String serviceId, bool isOnline) {
    state = {...state, serviceId: isOnline};
  }

  bool isOnline(String serviceId) => state[serviceId] ?? false;
}

final serviceStatusProvider =
    NotifierProvider<ServiceStatusNotifier, Map<String, bool>>(() {
  return ServiceStatusNotifier();
});
