import 'package:flutter/material.dart';

class SnackItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stockCount;
  final IconData icon;

  const SnackItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stockCount,
    this.icon = Icons.fastfood_rounded,
  });

  SnackItem copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    int? stockCount,
    IconData? icon,
  }) {
    return SnackItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stockCount: stockCount ?? this.stockCount,
      icon: icon ?? this.icon,
    );
  }
}
