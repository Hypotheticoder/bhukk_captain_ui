import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bhukkdelivery/notifiers/home_screen/master_dashboard_notifier.dart';

final masterDashboardProvider =
    NotifierProvider<MasterDashboardNotifier, MasterDashboardState>(() {
  return MasterDashboardNotifier();
});
