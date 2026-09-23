import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock/mock_data.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/monthly_analytics_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/firestore_transaction_repository.dart';
import '../../data/repositories/monthly_analytics_repository.dart';
import 'repository_providers.dart';

/// Local in-memory store for offline/demo operation.
class LocalTransactionNotifier extends StateNotifier<List<TransactionModel>> {
  LocalTransactionNotifier()
      : super(List<TransactionModel>.from(MockData.transactions));

  void add(TransactionModel tx) {
    state = <TransactionModel>[tx, ...state];
  }

  void delete(String id) {
    state = state.where((TransactionModel t) => t.id != id).toList();
  }
}

final StateNotifierProvider<LocalTransactionNotifier, List<TransactionModel>>
    localTransactionsProvider = StateNotifierProvider<LocalTransactionNotifier,
        List<TransactionModel>>((Ref ref) {
  return LocalTransactionNotifier();
});

class LocalBudgetNotifier extends StateNotifier<List<BudgetModel>> {
  LocalBudgetNotifier() : super(List<BudgetModel>.from(MockData.budgets));

  void updateBudget(BudgetModel updated) {
    state = state
        .map((BudgetModel b) => b.id == updated.id ? updated : b)
        .toList();
  }
}

final StateNotifierProvider<LocalBudgetNotifier, List<BudgetModel>>
    localBudgetsProvider =
    StateNotifierProvider<LocalBudgetNotifier, List<BudgetModel>>((Ref ref) {
  return LocalBudgetNotifier();
});

/// Real-time stream of all transactions for the current user.
/// Falls back to local store if signed out or without active Firebase connection.
final StreamProvider<List<TransactionModel>> transactionsProvider =
    StreamProvider<List<TransactionModel>>((Ref ref) {
  final FirestoreTransactionRepository? repo =
      ref.watch(transactionRepositoryProvider);
  if (repo == null) {
    final List<TransactionModel> local = ref.watch(localTransactionsProvider);
    return Stream<List<TransactionModel>>.value(local);
  }
  return repo.watchAll();
});

final StreamProvider<List<CategoryModel>> categoriesProvider =
    StreamProvider<List<CategoryModel>>((Ref ref) {
  final FirestoreTransactionRepository? repo =
      ref.watch(transactionRepositoryProvider);
  if (repo == null) {
    return Stream<List<CategoryModel>>.value(MockData.categories);
  }
  return repo.watchCategories();
});

final StreamProvider<List<BudgetModel>> budgetsProvider =
    StreamProvider<List<BudgetModel>>((Ref ref) {
  final FirestoreTransactionRepository? repo =
      ref.watch(transactionRepositoryProvider);
  if (repo == null) {
    final List<BudgetModel> local = ref.watch(localBudgetsProvider);
    return Stream<List<BudgetModel>>.value(local);
  }
  return repo.watchBudgets();
});

/// Derived totals — `income / expense / balance` for the current dataset.
final Provider<({double income, double expense, double balance})>
    totalsProvider =
    Provider<({double income, double expense, double balance})>(
  (Ref ref) {
    final AsyncValue<List<TransactionModel>> async =
        ref.watch(transactionsProvider);
    return async.maybeWhen(
      data: (List<TransactionModel> txs) {
        double income = 0;
        double expense = 0;
        for (final TransactionModel t in txs) {
          if (t.isIncome) {
            income += t.amount;
          } else {
            expense += t.amount;
          }
        }
        return (income: income, expense: expense, balance: income - expense);
      },
      orElse: () => (income: 0.0, expense: 0.0, balance: 0.0),
    );
  },
);

/// Currently selected month — drives [monthlyAnalyticsProvider].
/// Defaults to the current calendar month.
class SelectedMonth {
  const SelectedMonth(this.year, this.month);
  final int year;
  final int month;
}

final StateProvider<SelectedMonth> selectedMonthProvider =
    StateProvider<SelectedMonth>((Ref ref) {
  final DateTime now = DateTime.now();
  return SelectedMonth(now.year, now.month);
});

/// Monthly analytics — prefers the pre-aggregated doc, falls back to
/// computing it client-side from the transactions stream.
final Provider<MonthlyAnalytics> monthlyAnalyticsProvider =
    Provider<MonthlyAnalytics>((Ref ref) {
  final SelectedMonth m = ref.watch(selectedMonthProvider);
  final AsyncValue<List<TransactionModel>> txs =
      ref.watch(transactionsProvider);
  return txs.maybeWhen(
    data: (List<TransactionModel> list) =>
        MonthlyAnalyticsRepository.computeFromTransactions(
            list, m.year, m.month),
    orElse: () => MonthlyAnalytics.empty(
        '${m.year}-${m.month.toString().padLeft(2, '0')}'),
  );
});

/// Filter on the Transactions screen.
enum TxFilter { all, income, expense }

final StateProvider<TxFilter> transactionFilterProvider =
    StateProvider<TxFilter>((Ref ref) => TxFilter.all);
