/// Single source of truth for Firestore collection paths.
/// Change the schema once, here, instead of hunting through repositories.
class FirestorePaths {
  FirestorePaths._();

  // ---------- Top-level collections ----------
  static const String users = 'users';
  static const String defaultCategories = 'categories'; // app-wide defaults

  // ---------- User-scoped subcollections ----------
  static String user(String uid) => '$users/$uid';
  static String userTransactions(String uid) => '$users/$uid/transactions';
  static String userBudgets(String uid) => '$users/$uid/budgets';
  static String userCategories(String uid) => '$users/$uid/categories';
  static String userNotifications(String uid) =>
      '$users/$uid/notifications';

  // Monthly aggregations — populated by a Cloud Function trigger or
  // computed client-side as a write-through cache.
  static String userMonthlyAnalytics(String uid) =>
      '$users/$uid/analytics_monthly';

  // Doc id format: '2026-05'
  static String monthlyAnalyticsDoc(String uid, int year, int month) =>
      '$users/$uid/analytics_monthly/${_yearMonth(year, month)}';

  static String _yearMonth(int year, int month) =>
      '$year-${month.toString().padLeft(2, '0')}';
}
