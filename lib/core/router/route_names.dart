/// Static route paths & names — keep them in one place so refactors are safe.
class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';

  // Bottom-tab roots
  static const String home = '/home';
  static const String analytics = '/analytics';
  static const String budgets = '/budgets';
  static const String profile = '/profile';

  // Sub routes
  static const String transactions = '/transactions';
  static const String addTransaction = '/transactions/add';
  static const String categories = '/categories';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
}
