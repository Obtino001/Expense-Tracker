import 'package:flutter/material.dart';

/// Category model. Stored in Firestore under `users/{uid}/categories/{id}`
/// (or in the global `categories/` collection for defaults).
///
/// [IconData] and [Color] can't be serialized directly — we persist the
/// icon's code point + font family and the color's ARGB int, then rebuild
/// on the client.
@immutable
class CategoryModel {
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
      icon: IconData(
        json['iconCode'] as int,
        fontFamily: json['iconFontFamily'] as String?,
        fontPackage: json['iconFontPackage'] as String?,
      ),
      color: Color(json['color'] as int),
      isIncome: json['isIncome'] as bool? ?? false,
    );
  }
}
