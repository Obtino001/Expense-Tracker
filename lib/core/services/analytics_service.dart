import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';

/// Type-safe wrapper around Firebase Analytics.
/// Keep event names in one file so they stay consistent across the app.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Plug into [GoRouter] (or any [Navigator]) to auto-log screen views.
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ---------- Identification ----------
  Future<void> setUser(String? uid) => _analytics.setUserId(id: uid);

  // ---------- Lifecycle ----------
  Future<void> logSignUp(String method) =>
      _analytics.logSignUp(signUpMethod: method);

  Future<void> logLogin(String method) =>
      _analytics.logLogin(loginMethod: method);

  // ---------- Domain events ----------
  Future<void> logTransactionAdded({
    required double amount,
    required String type, // 'income' | 'expense'
    required String category,
  }) {
    return _analytics.logEvent(
      name: 'transaction_added',
      parameters: <String, Object>{
        'amount': amount,
        'type': type,
        'category': category,
      },
    );
  }

  Future<void> logBudgetCreated({
    required String category,
    required double limit,
  }) {
    return _analytics.logEvent(
      name: 'budget_created',
      parameters: <String, Object>{
        'category': category,
        'limit': limit,
      },
    );
  }

  Future<void> logScreen(String name) =>
      _analytics.logScreenView(screenName: name);
}
