import 'package:bhukkdelivery/models/snack_item.dart';
import 'package:bhukkdelivery/notifiers/snacks_inventory_screen/snacks_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SnacksNotifier extends Notifier<SnacksState> {
  @override
  SnacksState build() {
    return SnacksState(snacks: _getInitialMockSnacks());
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateQuantity(String id, int delta) {
    final updatedSnacks = state.snacks.map((snack) {
      if (snack.id == id) {
        final newCount = (snack.stockCount + delta).clamp(0, 9999);
        return snack.copyWith(stockCount: newCount);
      }
      return snack;
    }).toList();

    state = state.copyWith(snacks: updatedSnacks);
  }

  void addItem(SnackItem item) {
    state = state.copyWith(snacks: [...state.snacks, item]);
  }

  void removeItem(String id) {
    final updated = state.snacks.where((s) => s.id != id).toList();
    state = state.copyWith(snacks: updated);
  }

  Future<void> saveInventory() async {
    state = state.copyWith(isSaving: true);
    // Simulate network save
    await Future.delayed(const Duration(milliseconds: 1200));
    state = state.copyWith(isSaving: false);
  }

  String generateId() {
    return 's${DateTime.now().millisecondsSinceEpoch}';
  }

  List<SnackItem> _getInitialMockSnacks() {
    return const [
      SnackItem(
        id: 's1',
        name: 'Lays Classic',
        category: 'Chips',
        price: 20.0,
        stockCount: 15,
        icon: Icons.set_meal_rounded,
      ),
      SnackItem(
        id: 's2',
        name: 'Doritos Nacho Cheese',
        category: 'Chips',
        price: 35.0,
        stockCount: 8,
        icon: Icons.breakfast_dining_rounded,
      ),
      SnackItem(
        id: 's3',
        name: 'Coca-Cola Can',
        category: 'Beverages',
        price: 40.0,
        stockCount: 24,
        icon: Icons.local_cafe_rounded,
      ),
      SnackItem(
        id: 's4',
        name: 'Oreo Original',
        category: 'Sweets',
        price: 30.0,
        stockCount: 12,
        icon: Icons.cookie_rounded,
      ),
      SnackItem(
        id: 's5',
        name: 'Dairy Milk Silk',
        category: 'Sweets',
        price: 85.0,
        stockCount: 5,
        icon: Icons.icecream_rounded,
      ),
      SnackItem(
        id: 's6',
        name: 'Red Bull Energy',
        category: 'Beverages',
        price: 125.0,
        stockCount: 10,
        icon: Icons.sports_bar_rounded,
      ),
      SnackItem(
        id: 's7',
        name: 'Kurkure Masala Munch',
        category: 'Chips',
        price: 20.0,
        stockCount: 18,
        icon: Icons.lunch_dining_rounded,
      ),
      SnackItem(
        id: 's8',
        name: 'Sprite Can',
        category: 'Beverages',
        price: 40.0,
        stockCount: 20,
        icon: Icons.local_drink_rounded,
      ),
      SnackItem(
        id: 's9',
        name: '5 Star Chocolate',
        category: 'Sweets',
        price: 25.0,
        stockCount: 14,
        icon: Icons.star_rounded,
      ),
      SnackItem(
        id: 's10',
        name: 'Hide & Seek Biscuit',
        category: 'Biscuits',
        price: 30.0,
        stockCount: 10,
        icon: Icons.bakery_dining_rounded,
      ),
      SnackItem(
        id: 's11',
        name: 'Parle-G Gold',
        category: 'Biscuits',
        price: 15.0,
        stockCount: 25,
        icon: Icons.brunch_dining_rounded,
      ),
    ];
  }
}
