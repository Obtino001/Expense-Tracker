import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../models/budget_model.dart';
import '../models/category_model.dart';
import '../models/notification_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';

/// Hard-coded sample data matching the reference design.
/// Seamless fallback when offline or without live Firebase credentials.
class MockData {
  MockData._();

  // ---------- User ----------
  static const UserModel user = UserModel(
    id: 'u1',
    name: 'Morgan Ross',
    email: 'morgan@picky.app',
    avatarUrl: null,
  );

  // ---------- Categories ----------
  static const List<CategoryModel> categories = <CategoryModel>[
    CategoryModel(
      id: 'c1',
      name: 'Housing',
      icon: Icons.home_rounded,
      color: AppColors.catHousing,
    ),
    CategoryModel(
      id: 'c2',
      name: 'Food & Drink',
      icon: Icons.coffee_rounded,
      color: AppColors.catFood,
    ),
    CategoryModel(
      id: 'c3',
      name: 'Groceries',
      icon: Icons.shopping_cart_rounded,
      color: AppColors.catGroceries,
    ),
    CategoryModel(
      id: 'c4',
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      color: AppColors.catShopping,
    ),
    CategoryModel(
      id: 'c5',
      name: 'Transport',
      icon: Icons.directions_car_rounded,
      color: AppColors.catTransport,
    ),
    CategoryModel(
      id: 'c6',
      name: 'Entertainment',
      icon: Icons.movie_rounded,
      color: AppColors.catEntertainment,
    ),
    CategoryModel(
      id: 'c7',
      name: 'Salary',
      icon: Icons.payments_rounded,
      color: AppColors.success,
      isIncome: true,
    ),
  ];

  static CategoryModel _cat(String id) =>
      categories.firstWhere((CategoryModel c) => c.id == id);

  // ---------- Transactions ----------
  // Total expenses: 5.40 + 63.20 + 380 + 128 + 96 + 184.80 + 306.60 + 76 = $1,240.00
  // Total income: $6,060.50
  // Net Balance: $4,820.50
  static List<TransactionModel> transactions = <TransactionModel>[
    TransactionModel(
      id: 't1',
      title: 'Blue Bottle',
      amount: 5.40,
      date: DateTime.now(), // 8:24 AM
      category: _cat('c2'),
      type: TransactionType.expense,
      note: 'Morning coffee',
    ),
    TransactionModel(
      id: 't2',
      title: 'Whole Foods',
      amount: 63.20,
      date: DateTime.now().subtract(const Duration(days: 1)),
      category: _cat('c3'),
      type: TransactionType.expense,
      note: 'Fresh produce & snacks',
    ),
    TransactionModel(
      id: 't3',
      title: 'Housing Payment',
      amount: 380.00,
      date: DateTime.now().subtract(const Duration(days: 2)),
      category: _cat('c1'),
      type: TransactionType.expense,
      note: 'Monthly allocation',
    ),
    TransactionModel(
      id: 't4',
      title: 'Shopping Boutique',
      amount: 128.00,
      date: DateTime.now().subtract(const Duration(days: 3)),
      category: _cat('c4'),
      type: TransactionType.expense,
    ),
    TransactionModel(
      id: 't5',
      title: 'Transport Pass',
      amount: 96.00,
      date: DateTime.now().subtract(const Duration(days: 4)),
      category: _cat('c5'),
      type: TransactionType.expense,
    ),
    TransactionModel(
      id: 't6',
      title: 'Supermarket Stockup',
      amount: 184.80,
      date: DateTime.now().subtract(const Duration(days: 5)),
      category: _cat('c3'),
      type: TransactionType.expense,
    ),
    TransactionModel(
      id: 't7',
      title: 'Dining & Drinks',
      amount: 306.60,
      date: DateTime.now().subtract(const Duration(days: 6)),
      category: _cat('c2'),
      type: TransactionType.expense,
    ),
    TransactionModel(
      id: 't8',
      title: 'Cinema & Streaming',
      amount: 76.00,
      date: DateTime.now().subtract(const Duration(days: 7)),
      category: _cat('c6'),
      type: TransactionType.expense,
    ),
    TransactionModel(
      id: 't9',
      title: 'Direct Deposit Payroll',
      amount: 6060.50,
      date: DateTime.now().subtract(const Duration(days: 10)),
      category: _cat('c7'),
      type: TransactionType.income,
      note: 'Monthly salary',
    ),
  ];

  // ---------- Budgets (Total: $2,000, Spent: $1,240, Remaining: $760) ----------
  static List<BudgetModel> budgets = <BudgetModel>[
    BudgetModel(
      id: 'b1',
      category: _cat('c1'),
      limit: 380,
      spent: 380,
      period: 'October',
    ),
    BudgetModel(
      id: 'b2',
      category: _cat('c2'),
      limit: 450,
      spent: 312,
      period: 'October',
    ),
    BudgetModel(
      id: 'b3',
      category: _cat('c3'),
      limit: 300,
      spent: 248,
      period: 'October',
    ),
    BudgetModel(
      id: 'b4',
      category: _cat('c4'),
      limit: 220,
      spent: 128,
      period: 'October',
    ),
    BudgetModel(
      id: 'b5',
      category: _cat('c5'),
      limit: 160,
      spent: 96,
      period: 'October',
    ),
    BudgetModel(
      id: 'b6',
      category: _cat('c6'),
      limit: 490,
      spent: 76,
      period: 'October',
    ),
  ];

  // ---------- Notifications ----------
  static List<NotificationModel> notifications = <NotificationModel>[
    NotificationModel(
      id: 'n1',
      title: 'Housing Budget Maxed',
      message: 'You have reached 100% of your Housing limit (\$380).',
      time: DateTime.now().subtract(const Duration(minutes: 15)),
      type: NotificationType.warning,
    ),
    NotificationModel(
      id: 'n2',
      title: 'Monthly Insight',
      message: 'You spent \$108 less than last month. Keep being picky 👏',
      time: DateTime.now().subtract(const Duration(hours: 1)),
      type: NotificationType.info,
    ),
  ];

  /// Weekly spending data for the analytics chart (Mon → Sun).
  /// M: 42, T: 68, W: 30, T: 88, F: 51, S: 120, S: 35
  static const List<double> weeklySpending = <double>[
    42, 68, 30, 88, 51, 120, 35,
  ];

  static const List<String> weeklyDays = <String>[
    'M', 'T', 'W', 'T', 'F', 'S', 'S'
  ];

  /// Monthly cashflow (last 6 months).
  static const List<({String month, double income, double expense})>
      monthlyFlow = <({String month, double income, double expense})>[
    (month: 'May', income: 5800, expense: 1350),
    (month: 'Jun', income: 6000, expense: 1420),
    (month: 'Jul', income: 5900, expense: 1380),
    (month: 'Aug', income: 6100, expense: 1410),
    (month: 'Sep', income: 6050, expense: 1348),
    (month: 'Oct', income: 6060.50, expense: 1240.00),
  ];
}
