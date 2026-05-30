export 'package:bhukkdelivery/notifiers/medicine_screen/medicine_notifier.dart';
import 'package:bhukkdelivery/notifiers/medicine_screen/medicine_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final medicineProvider = NotifierProvider<MedicineNotifier, MedicineState>(() {
  return MedicineNotifier();
});
