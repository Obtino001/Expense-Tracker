import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock/mock_data.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/monthly_analytics_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/local_store.dart';
import '../../data/repositories/monthly_analytics_repository.dart';
import 'repository_providers.dart';

String monthKey(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}';

class LocalTransactionNotifier extends LocalListStore<TransactionModel> {
  LocalTransactionNotifier() : super(
    storageKey: 'picky.transactions.v1',
    defaults: MockData.transactions,
    decode: TransactionModel.fromJson,
    encode: (TransactionModel tx) => tx.toJson()..['date'] = tx.date.toIso8601String(),
  );

  Future<void> add(TransactionModel tx) => change((items) {
    final result = <TransactionModel>[tx, ...items.where((item) => item.id != tx.id)];
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  });
  Future<void> update(TransactionModel tx) => add(tx);
  Future<void> delete(String id) => change((items) => items.where((item) => item.id != id).toList());
}

final localTransactionsProvider = StateNotifierProvider<LocalTransactionNotifier, List<TransactionModel>>((ref) => LocalTransactionNotifier());

class LocalCategoryNotifier extends LocalListStore<CategoryModel> {
  LocalCategoryNotifier() : super(
    storageKey: 'picky.categories.v1', defaults: MockData.categories,
    decode: CategoryModel.fromJson, encode: (item) => item.toJson(),
  );
  Future<void> save(CategoryModel category) => change((items) {
    final index = items.indexWhere((item) => item.id == category.id);
    if (index < 0) { items.add(category); } else { items[index] = category; }
    return items;
  });
  Future<void> delete(String id) => change((items) => items.where((item) => item.id != id).toList());
}
final localCategoriesProvider = StateNotifierProvider<LocalCategoryNotifier, List<CategoryModel>>((ref) => LocalCategoryNotifier());

class LocalBudgetNotifier extends LocalListStore<BudgetModel> {
  LocalBudgetNotifier() : super(
    storageKey: 'picky.budgets.v1',
    defaults: MockData.budgets.map((b) => BudgetModel(id: b.id, category: b.category, limit: b.limit, spent: b.spent, period: monthKey(DateTime.now()))).toList(),
    decode: BudgetModel.fromJson, encode: (item) => item.toJson(),
  );
  Future<void> add(BudgetModel budget) => updateBudget(budget);
  Future<void> updateBudget(BudgetModel budget) => change((items) {
    final index = items.indexWhere((item) => item.id == budget.id);
    if (index < 0) { items.add(budget); } else { items[index] = budget; }
    return items;
  });
  Future<void> delete(String id) => change((items) => items.where((item) => item.id != id).toList());
}
final localBudgetsProvider = StateNotifierProvider<LocalBudgetNotifier, List<BudgetModel>>((ref) => LocalBudgetNotifier());

final transactionsProvider = StreamProvider<List<TransactionModel>>((ref) async* {
  final repo = ref.watch(transactionRepositoryProvider);
  if (repo != null) { yield* repo.watchAll(); return; }
  ref.watch(localTransactionsProvider);
  final store = ref.read(localTransactionsProvider.notifier);
  await store.ready;
  yield ref.read(localTransactionsProvider);
});

final categoriesProvider = StreamProvider<List<CategoryModel>>((ref) async* {
  final repo = ref.watch(transactionRepositoryProvider);
  if (repo != null) { yield* repo.watchCategories(); return; }
  ref.watch(localCategoriesProvider);
  final store = ref.read(localCategoriesProvider.notifier);
  await store.ready;
  yield ref.read(localCategoriesProvider);
});

final budgetsProvider = StreamProvider<List<BudgetModel>>((ref) async* {
  final repo = ref.watch(transactionRepositoryProvider);
  final month = ref.watch(selectedMonthProvider);
  final txs = ref.watch(transactionsProvider).valueOrNull ?? <TransactionModel>[];
  final categories = ref.watch(categoriesProvider).valueOrNull ?? <CategoryModel>[];
  final key = '${month.year}-${month.month.toString().padLeft(2, '0')}';
  List<BudgetModel> derive(List<BudgetModel> budgets) => budgets.where((b) => b.period == key).map((b) {
    final spent = txs.where((t) => !t.isIncome && t.category.id == b.category.id && t.date.year == month.year && t.date.month == month.month).fold(0.0, (total, t) => total + t.amount);
    final category = categories.where((c) => c.id == b.category.id).firstOrNull ?? b.category;
    return BudgetModel(id: b.id, userId: b.userId, category: category, limit: b.limit, spent: spent, period: b.period);
  }).toList();
  if (repo != null) { yield* repo.watchBudgets().map(derive); return; }
  ref.watch(localBudgetsProvider);
  final store = ref.read(localBudgetsProvider.notifier);
  await store.ready;
  yield derive(ref.read(localBudgetsProvider));
});

class BudgetActions {
  BudgetActions(this.ref);
  final Ref ref;
  Future<void> saveBudget(BudgetModel budget) async {
    final repo = ref.read(transactionRepositoryProvider);
    if (repo == null) { await ref.read(localBudgetsProvider.notifier).updateBudget(budget); }
    else { await repo.setBudget(budget); }
  }
  Future<void> deleteBudget(String id) async {
    final repo = ref.read(transactionRepositoryProvider);
    if (repo == null) { await ref.read(localBudgetsProvider.notifier).delete(id); }
    else { await repo.deleteBudget(id); }
  }
}
final budgetActionsProvider = Provider<BudgetActions>((ref) => BudgetActions(ref));

class TransactionActions {
  TransactionActions(this.ref);
  final Ref ref;
  Future<void> save(TransactionModel transaction) async {
    final repo = ref.read(transactionRepositoryProvider);
    if (repo == null) { await ref.read(localTransactionsProvider.notifier).add(transaction); }
    else { await repo.update(transaction.copyWith(userId: repo.uid)); }
  }
  Future<void> delete(String id) async {
    final repo = ref.read(transactionRepositoryProvider);
    if (repo == null) { await ref.read(localTransactionsProvider.notifier).delete(id); }
    else { await repo.delete(id); }
  }
}
final transactionActionsProvider = Provider<TransactionActions>((ref) => TransactionActions(ref));

class CategoryActions {
  CategoryActions(this.ref);
  final Ref ref;
  Future<void> save(CategoryModel category) async {
    final repo = ref.read(transactionRepositoryProvider);
    if (repo == null) { await ref.read(localCategoriesProvider.notifier).save(category); }
    else { await repo.addCategory(category); }
  }
  Future<void> delete(String id) async {
    final repo = ref.read(transactionRepositoryProvider);
    if (repo == null) { await ref.read(localCategoriesProvider.notifier).delete(id); }
    else { await repo.deleteCategory(id); }
  }
}
final categoryActionsProvider = Provider<CategoryActions>((ref) => CategoryActions(ref));

final totalsProvider = Provider<({double income, double expense, double balance})>((ref) {
  final txs = ref.watch(transactionsProvider).valueOrNull ?? <TransactionModel>[];
  double income = 0;
  double expense = 0;
  for (final t in txs) { if (t.isIncome) { income += t.amount; } else { expense += t.amount; } }
  return (income: income, expense: expense, balance: income - expense);
});

class SelectedMonth {
  const SelectedMonth(this.year, this.month);
  final int year;
  final int month;
}
final selectedMonthProvider = StateProvider<SelectedMonth>((ref) {
  final now = DateTime.now();
  return SelectedMonth(now.year, now.month);
});
final monthlyAnalyticsProvider = Provider<MonthlyAnalytics>((ref) {
  final month = ref.watch(selectedMonthProvider);
  return MonthlyAnalyticsRepository.computeFromTransactions(ref.watch(transactionsProvider).valueOrNull ?? <TransactionModel>[], month.year, month.month);
});

enum TxFilter { all, income, expense }
final transactionFilterProvider = StateProvider<TxFilter>((ref) => TxFilter.all);

List<TransactionModel> filterTransactions(List<TransactionModel> all, {TxFilter type = TxFilter.all, String query = '', DateTimeRangeFilter? range}) {
  final search = query.trim().toLowerCase();
  final result = all.where((t) {
    if (type == TxFilter.income && !t.isIncome || type == TxFilter.expense && t.isIncome) return false;
    if (search.isNotEmpty && !'${t.title} ${t.category.name} ${t.note}'.toLowerCase().contains(search)) return false;
    if (range != null && (t.date.isBefore(range.start) || !t.date.isBefore(range.endExclusive))) return false;
    return true;
  }).toList();
  result.sort((a, b) => b.date.compareTo(a.date));
  return result;
}

class DateTimeRangeFilter {
  const DateTimeRangeFilter(this.start, this.endExclusive);
  final DateTime start;
  final DateTime endExclusive;
}

String? validateTransactionAmount(String? input) {
  final value = input?.trim() ?? '';
  if (value.isEmpty) return 'Enter an amount';
  final parsed = double.tryParse(value);
  if (parsed == null || !parsed.isFinite || parsed <= 0 || parsed > 999999999.99) return 'Enter an amount between 0.01 and 999,999,999.99';
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) return 'Use up to two decimal places';
  return null;
}

String? validateTransactionTitle(String? input) {
  if (input == null || input.trim().isEmpty) return 'Give this transaction a title';
  if (input.trim().length > 80) return 'Use 80 characters or fewer';
  return null;
}
