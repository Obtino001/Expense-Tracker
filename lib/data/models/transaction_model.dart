import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'category_model.dart';

enum TransactionType { income, expense }

@immutable
class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    this.note = '',
    this.userId = '',
  });

  final String id;
  final String userId; // Firestore owner — used by security rules.
  final String title;
  final double amount;
  final DateTime date;
  final CategoryModel category;
  final TransactionType type;
  final String note;

  bool get isIncome => type == TransactionType.income;
  double get signedAmount => isIncome ? amount : -amount;

  TransactionModel copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    DateTime? date,
    CategoryModel? category,
    TransactionType? type,
    String? note,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      type: type ?? this.type,
      note: note ?? this.note,
    );
  }

  // ---------- Firestore ----------
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'userId': userId,
        'title': title,
        'amount': amount,
        // Firestore stores DateTime as Timestamp natively.
        'date': Timestamp.fromDate(date),
        'category': category.toJson(),
        'type': type.name, // 'income' | 'expense'
        'note': note,
        // Helpful for monthly aggregation queries without re-parsing dates.
        'yearMonth':
            '${date.year}-${date.month.toString().padLeft(2, '0')}',
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: (json['date'] as Timestamp).toDate(),
      category:
          CategoryModel.fromJson(Map<String, dynamic>.from(json['category'])),
      type: TransactionType.values.byName(json['type'] as String),
      note: json['note'] as String? ?? '',
    );
  }
}
