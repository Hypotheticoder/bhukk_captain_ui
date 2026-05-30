import 'package:flutter_riverpod/flutter_riverpod.dart';

class AmbulanceState {
  final int totalBookings;
  final int completedBookings;
  final int activeBookings;
  final double earnings;
  final double avgResponseTime; // minutes

  const AmbulanceState({
    this.totalBookings = 16,
    this.completedBookings = 14,
    this.activeBookings = 2,
    this.earnings = 12400,
    this.avgResponseTime = 8.5,
  });

  double get completionRate =>
      totalBookings > 0 ? (completedBookings / totalBookings) * 100 : 0;

  double get avgEarnings =>
      completedBookings > 0 ? earnings / completedBookings : 0;
}

class AmbulanceNotifier extends Notifier<AmbulanceState> {
  @override
  AmbulanceState build() => const AmbulanceState();
}
