import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Per-month roll-up of a user's spending. Lives at
/// `users/{uid}/analytics_monthly/{yyyy-MM}`.
///
/// In production, populate this via a Cloud Function `onWrite` trigger on
/// the transactions collection. The Flutter side can also derive it as
/// a write-through cache (see `MonthlyAnalyticsService`).
@immutable
class MonthlyAnalytics {
  const MonthlyAnalytics({
    required this.yearMonth,
    required this.income,
    required this.expense,
    required this.byCategory,
    required this.dailyExpense,
    this.transactionCount = 0,
  });

  /// '2026-05'
  final String yearMonth;
  final double income;
  final double expense;

  /// `categoryName → totalSpent`
  final Map<String, double> byCategory;

  /// Length-31 list, indexed by day-of-month (0-based; day 1 lives at index 0).
  final List<double> dailyExpense;

  final int transactionCount;

  double get balance => income - expense;

  // ---------- Firestore ----------
  Map<String, dynamic> toJson() => <String, dynamic>{
        'yearMonth': yearMonth,
        'income': income,
        'expense': expense,
        'byCategory': byCategory,
        'dailyExpense': dailyExpense,
        'transactionCount': transactionCount,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  factory MonthlyAnalytics.fromJson(Map<String, dynamic> json) {
    return MonthlyAnalytics(
      yearMonth: json['yearMonth'] as String,
      income: (json['income'] as num? ?? 0).toDouble(),
      expense: (json['expense'] as num? ?? 0).toDouble(),
      byCategory: Map<String, double>.from(
        (json['byCategory'] as Map<dynamic, dynamic>? ?? <String, dynamic>{})
            .map<String, double>(
          (dynamic k, dynamic v) =>
              MapEntry<String, double>(k as String, (v as num).toDouble()),
        ),
      ),
      dailyExpense: List<double>.from(
        (json['dailyExpense'] as List<dynamic>? ?? <dynamic>[])
            .map<double>((dynamic v) => (v as num).toDouble()),
      ),
      transactionCount: json['transactionCount'] as int? ?? 0,
    );
  }

  factory MonthlyAnalytics.empty(String yearMonth) => MonthlyAnalytics(
        yearMonth: yearMonth,
        income: 0,
        expense: 0,
        byCategory: const <String, double>{},
        dailyExpense: List<double>.filled(31, 0),
      );
}
