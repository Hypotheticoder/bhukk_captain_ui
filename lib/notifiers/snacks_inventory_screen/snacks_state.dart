import 'package:bhukkdelivery/models/snack_item.dart';

class SnacksState {
  final List<SnackItem> snacks;
  final String selectedCategory;
  final String searchQuery;
  final bool isSaving;

  const SnacksState({
    required this.snacks,
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.isSaving = false,
  });

  SnacksState copyWith({
    List<SnackItem>? snacks,
    String? selectedCategory,
    String? searchQuery,
    bool? isSaving,
  }) {
    return SnacksState(
      snacks: snacks ?? this.snacks,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  // Get filtered snacks (by category + search)
  List<SnackItem> get filteredSnacks {
    var result = snacks;
    if (selectedCategory != 'All') {
      result = result.where((s) => s.category == selectedCategory).toList();
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result
          .where((s) =>
              s.name.toLowerCase().contains(q) ||
              s.category.toLowerCase().contains(q))
          .toList();
    }
    return result;
  }

  // Categories list starting with 'All'
  List<String> get categories {
    final cats = snacks.map((e) => e.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  // Stats
  int get totalProducts => snacks.length;
  int get totalUnits => snacks.fold(0, (sum, s) => sum + s.stockCount);
  double get totalValue =>
      snacks.fold(0.0, (sum, s) => sum + (s.price * s.stockCount));
}
