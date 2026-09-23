import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_model.dart';

/// A single source of truth for the selected month's charts and insights.
class InsightsSummary {
  InsightsSummary.fromTransactions(
    List<TransactionModel> transactions,
    this.month, {
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    elapsedDays = month.year == today.year && month.month == today.month
        ? today.day
        : month.isAfter(DateTime(today.year, today.month))
            ? 0
            : daysInMonth;
    daily = List<double>.filled(daysInMonth, 0);
    final previous = DateTime(month.year, month.month - 1);
    final previousDays = DateTime(month.year, month.month, 0).day;
    final comparisonDays = elapsedDays == daysInMonth
        ? previousDays
        : elapsedDays.clamp(0, previousDays);
    for (final transaction in transactions) {
      final date = transaction.date;
      if (date.year == month.year && date.month == month.month) {
        count++;
        if (transaction.isIncome) {
          income += transaction.amount;
        } else {
          expense += transaction.amount;
          daily[date.day - 1] += transaction.amount;
          final id = transaction.category.id;
          categories[id] = transaction.category;
          byCategory[id] = (byCategory[id] ?? 0) + transaction.amount;
        }
      }
      if (!transaction.isIncome &&
          date.year == previous.year &&
          date.month == previous.month &&
          date.day <= comparisonDays) {
        previousExpense += transaction.amount;
      }
    }
  }

  final DateTime month;
  double income = 0;
  double expense = 0;
  double previousExpense = 0;
  int count = 0;
  late final int elapsedDays;
  late final List<double> daily;
  final Map<String, double> byCategory = <String, double>{};
  final Map<String, CategoryModel> categories = <String, CategoryModel>{};

  double get dailyAverage => elapsedDays > 0 ? expense / elapsedDays : 0;
  double? get changePercent => previousExpense > 0
      ? (expense - previousExpense) / previousExpense * 100
      : null;
  List<MapEntry<String, double>> get rankedCategories => byCategory.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  List<double> get cumulative {
    double sum = 0;
    return daily.map((value) => sum += value).toList();
  }
}
