import 'package:bhukkdelivery/notifiers/snacks_inventory_screen/snacks_notifier.dart';
import 'package:bhukkdelivery/notifiers/snacks_inventory_screen/snacks_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final snacksProvider = NotifierProvider<SnacksNotifier, SnacksState>(
  () => SnacksNotifier(),
);
