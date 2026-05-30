import 'package:bhukkdelivery/notifiers/orders_screen/live_jobs_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final liveJobsProvider =
    NotifierProvider<LiveJobsNotifier, LiveJobsState>(() {
  return LiveJobsNotifier();
});
