import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase/firestore_paths.dart';
import '../models/monthly_analytics_model.dart';
import '../models/transaction_model.dart';

/// Read pre-aggregated month docs (preferred) or compute them on the fly
/// from the raw transactions stream.
class MonthlyAnalyticsRepository {
  MonthlyAnalyticsRepository({required this.uid, FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  final String uid;

  static String _key(int year, int month) =>
      '$year-${month.toString().padLeft(2, '0')}';

  /// Live stream of a single month's pre-aggregated doc.
  /// Returns [MonthlyAnalytics.empty] if the doc doesn't exist yet.
  Stream<MonthlyAnalytics> watch(int year, int month) {
    final String id = _key(year, month);
    return _db
        .doc(FirestorePaths.monthlyAnalyticsDoc(uid, year, month))
        .snapshots()
        .map((DocumentSnapshot<Map<String, dynamic>> s) =>
            s.exists ? MonthlyAnalytics.fromJson(s.data()!)
                     : MonthlyAnalytics.empty(id));
  }

  /// Compute a [MonthlyAnalytics] from an in-memory list of transactions.
  /// Used as a write-through cache when there's no Cloud Function.
  static MonthlyAnalytics computeFromTransactions(
    Iterable<TransactionModel> txs,
    int year,
    int month,
  ) {
    final List<double> daily = List<double>.filled(31, 0);
    final Map<String, double> byCategory = <String, double>{};
    double income = 0;
    double expense = 0;
    int count = 0;

    for (final TransactionModel t in txs) {
      if (t.date.year != year || t.date.month != month) continue;
      count++;
      if (t.isIncome) {
        income += t.amount;
      } else {
        expense += t.amount;
        daily[t.date.day - 1] += t.amount;
        byCategory.update(
          t.category.name,
          (double v) => v + t.amount,
          ifAbsent: () => t.amount,
        );
      }
    }

    return MonthlyAnalytics(
      yearMonth: _key(year, month),
      income: income,
      expense: expense,
      byCategory: byCategory,
      dailyExpense: daily,
      transactionCount: count,
    );
  }

  /// Persist a freshly-computed aggregation back to Firestore.
  Future<void> upsert(MonthlyAnalytics analytics) {
    return _db
        .doc(FirestorePaths.userMonthlyAnalytics(uid) +
            '/${analytics.yearMonth}')
        .set(analytics.toJson(), SetOptions(merge: true));
  }
}
