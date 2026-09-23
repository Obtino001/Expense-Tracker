import 'package:flutter/material.dart';

/// Category model. Stored in Firestore under `users/{uid}/categories/{id}`
/// (or in the global `categories/` collection for defaults).
///
/// [IconData] and [Color] can't be serialized directly — we persist the
/// icon's code point + font family and the color's ARGB int, then rebuild
/// on the client.
@immutable
class CategoryModel {
  static const List<IconData> availableIcons = <IconData>[
    Icons.home_rounded,
    Icons.coffee_rounded,
    Icons.shopping_cart_rounded,
    Icons.shopping_bag_rounded,
    Icons.directions_car_rounded,
    Icons.movie_rounded,
    Icons.payments_rounded,
    Icons.restaurant_rounded,
    Icons.flight_rounded,
    Icons.favorite_rounded,
    Icons.fitness_center_rounded,
    Icons.school_rounded,
    Icons.pets_rounded,
    Icons.work_rounded,
    Icons.card_giftcard_rounded,
    Icons.savings_rounded,
    Icons.category_rounded,
    Icons.receipt_long_rounded,
  ];

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isIncome = false,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isIncome;

  CategoryModel copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    bool? isIncome,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isIncome: isIncome ?? this.isIncome,
    );
  }

  // ---------- Firestore ----------
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'iconCode': icon.codePoint,
        'iconFontFamily': icon.fontFamily,
        'iconFontPackage': icon.fontPackage,
        'color': color.toARGB32(),
        'isIncome': isIncome,
      };

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: availableIcons.firstWhere(
        (IconData icon) => icon.codePoint == json['iconCode'],
        orElse: () => Icons.category_rounded,
      ),
      color: Color(json['color'] as int),
      isIncome: json['isIncome'] as bool? ?? false,
    );
  }
}
