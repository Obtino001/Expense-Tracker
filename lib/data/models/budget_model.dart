import 'package:flutter/material.dart';

import 'category_model.dart';

@immutable
class BudgetModel {
  const BudgetModel({
    required this.id,
    required this.category,
    required this.limit,
    required this.spent,
    required this.period,
    this.userId = '',
  });

  final String id;
  final String userId;
  final CategoryModel category;
  final double limit;
  final double spent;
  final String period;

  double get progress => limit == 0 ? 0 : (spent / limit).clamp(0.0, 1.5);
  double get remaining => (limit - spent).clamp(0, double.infinity);
  bool get isOver => spent > limit;

  BudgetModel copyWith({double? spent}) => BudgetModel(
        id: id,
        userId: userId,
        category: category,
        limit: limit,
        spent: spent ?? this.spent,
        period: period,
      );

  // ---------- Firestore ----------
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'userId': userId,
        'category': category.toJson(),
        'limit': limit,
        // [spent] is server-derived in most setups, but we store it so the
        // UI can render instantly. A Cloud Function can keep it in sync.
        'spent': spent,
        'period': period,
      };

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      category:
          CategoryModel.fromJson(Map<String, dynamic>.from(json['category'])),
      limit: (json['limit'] as num).toDouble(),
      spent: (json['spent'] as num? ?? 0).toDouble(),
      period: json['period'] as String,
    );
  }
}
