import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

/// Type-safe wrapper around Firebase Analytics.
/// Keep event names in one file so they stay consistent across the app.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics? get _analytics {
    try {
      return Firebase.apps.isNotEmpty ? FirebaseAnalytics.instance : null;
    } catch (_) {
      return null;
    }
  }

  /// Plug into [GoRouter] (or any [Navigator]) to auto-log screen views.
  NavigatorObserver get observer {
    final FirebaseAnalytics? a = _analytics;
    return a != null
        ? FirebaseAnalyticsObserver(analytics: a)
        : NavigatorObserver();
  }

  // ---------- Identification ----------
  Future<void> setUser(String? uid) async {
    try {
      await _analytics?.setUserId(id: uid);
    } catch (_) {}
  }

  // ---------- Lifecycle ----------
  Future<void> logSignUp(String method) async {
    try {
      await _analytics?.logSignUp(signUpMethod: method);
    } catch (_) {}
  }

  Future<void> logLogin(String method) async {
    try {
      await _analytics?.logLogin(loginMethod: method);
    } catch (_) {}
  }

  // ---------- Domain events ----------
  Future<void> logTransactionAdded({
    required double amount,
    required String type, // 'income' | 'expense'
    required String category,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'transaction_added',
        parameters: <String, Object>{
          'amount': amount,
          'type': type,
          'category': category,
        },
      );
    } catch (_) {}
  }

  Future<void> logBudgetCreated({
    required String category,
    required double limit,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'budget_created',
        parameters: <String, Object>{
          'category': category,
          'limit': limit,
        },
      );
    } catch (_) {}
  }

  Future<void> logScreen(String name) async {
    try {
      await _analytics?.logScreenView(screenName: name);
    } catch (_) {}
  }
}
