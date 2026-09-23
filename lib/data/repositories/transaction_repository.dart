import 'package:uuid/uuid.dart';

import '../mock/mock_data.dart';
import '../models/budget_model.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

/// In-memory repository. Swap with a real backend by replacing this class.
class TransactionRepository {
  TransactionRepository();

  final Uuid _uuid = const Uuid();

  /// Simulated network delay so skeleton loaders have a chance to show.
  Future<List<TransactionModel>> getAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final List<TransactionModel> list = List<TransactionModel>.from(
      MockData.transactions,
    );
    list.sort((TransactionModel a, TransactionModel b) =>
        b.date.compareTo(a.date));
    return list;
  }

  Future<List<CategoryModel>> getCategories() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return MockData.categories;
  }

  Future<List<BudgetModel>> getBudgets() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return MockData.budgets;
  }

  Future<TransactionModel> add({
    required String title,
    required double amount,
    required DateTime date,
    required CategoryModel category,
    required TransactionType type,
    String note = '',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final TransactionModel tx = TransactionModel(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      date: date,
      category: category,
      type: type,
      note: note,
    );
    MockData.transactions.insert(0, tx);
    return tx;
  }

  Future<void> delete(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    MockData.transactions.removeWhere((TransactionModel t) => t.id == id);
  }
}
