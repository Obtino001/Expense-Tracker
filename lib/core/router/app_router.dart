import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/budget/presentation/screens/budget_screen.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/transactions/presentation/screens/add_transaction_screen.dart';
import '../../features/transactions/presentation/screens/transactions_screen.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/widgets/root_shell.dart';
import '../services/analytics_service.dart';
import '../animations/page_transitions.dart';
import 'route_names.dart';

class AppRouterConfig {
  AppRouterConfig(this.config);
  final GoRouter config;
}

/// Auth-aware GoRouter.
///
/// Redirect rules:
/// - While auth state is loading → splash
/// - Signed out + on a protected route → login
/// - Signed in + on an auth route → home
///
/// The router rebuilds on every [authStateProvider] tick, so the redirect
/// runs in lockstep with FirebaseAuth.
final Provider<AppRouterConfig> appRouterProvider = Provider<AppRouterConfig>(
  (Ref ref) {
    final GoRouter router = GoRouter(
      initialLocation: RouteNames.home,
      debugLogDiagnostics: false,
      observers: <NavigatorObserver>[
        AnalyticsService.instance.observer,
      ],
      refreshListenable: _RouterRefreshNotifier(ref),
      redirect: (BuildContext c, GoRouterState state) {
        final AsyncValue<User?> auth = ref.read(authStateProvider);
        final String loc = state.matchedLocation;

        // If explicitly visiting login/signup/onboarding, allow it
        final bool onAuthRoute = <String>{
          RouteNames.login,
          RouteNames.signup,
          RouteNames.onboarding,
          RouteNames.splash,
        }.contains(loc);

        final bool signedIn = auth.valueOrNull != null;
        if (signedIn && onAuthRoute && loc != RouteNames.splash) {
          return RouteNames.home;
        }
        return null;
      },
      routes: <RouteBase>[
        // ---- Public (no shell) ----
        GoRoute(
          path: RouteNames.splash,
          pageBuilder: (BuildContext c, GoRouterState s) =>
              fadeThroughPage(const SplashScreen(), s),
        ),
        GoRoute(
          path: RouteNames.onboarding,
          pageBuilder: (BuildContext c, GoRouterState s) =>
              fadeThroughPage(const OnboardingScreen(), s),
        ),
        GoRoute(
          path: RouteNames.login,
          pageBuilder: (BuildContext c, GoRouterState s) =>
              fadeThroughPage(const LoginScreen(), s),
        ),
        GoRoute(
          path: RouteNames.signup,
          pageBuilder: (BuildContext c, GoRouterState s) =>
              fadeThroughPage(const SignupScreen(), s),
        ),

        // ---- Authed shell ----
        ShellRoute(
          builder: (BuildContext c, GoRouterState s, Widget child) =>
              RootShell(child: child),
          routes: <RouteBase>[
            GoRoute(
              path: RouteNames.home,
              pageBuilder: (BuildContext c, GoRouterState s) =>
                  fadeThroughPage(const HomeScreen(), s),
            ),
            GoRoute(
              path: RouteNames.analytics,
              pageBuilder: (BuildContext c, GoRouterState s) =>
                  fadeThroughPage(const AnalyticsScreen(), s),
            ),
            GoRoute(
              path: RouteNames.budgets,
              pageBuilder: (BuildContext c, GoRouterState s) =>
                  fadeThroughPage(const BudgetScreen(), s),
            ),
            GoRoute(
              path: RouteNames.transactions,
              pageBuilder: (BuildContext c, GoRouterState s) =>
                  fadeThroughPage(const TransactionsScreen(), s),
            ),
            GoRoute(
              path: RouteNames.profile,
              pageBuilder: (BuildContext c, GoRouterState s) =>
                  fadeThroughPage(const ProfileScreen(), s),
            ),
          ],
        ),

        // ---- Authed modals ----
        GoRoute(
          path: RouteNames.addTransaction,
          pageBuilder: (BuildContext c, GoRouterState s) =>
              slideUpPage(const AddTransactionScreen(), s),
        ),
        GoRoute(
          path: RouteNames.categories,
          pageBuilder: (BuildContext c, GoRouterState s) =>
              slideUpPage(const CategoriesScreen(), s),
        ),
        GoRoute(
          path: RouteNames.notifications,
          pageBuilder: (BuildContext c, GoRouterState s) =>
              slideUpPage(const NotificationsScreen(), s),
        ),
        GoRoute(
          path: RouteNames.settings,
          pageBuilder: (BuildContext c, GoRouterState s) =>
              slideUpPage(const SettingsScreen(), s),
        ),
      ],
    );

    ref.onDispose(router.dispose);
    return AppRouterConfig(router);
  },
);

/// Bridges [authStateProvider] into a [Listenable] the router can react to.
/// Without this, GoRouter only checks the redirect on user-initiated nav.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    _sub = ref.listen<AsyncValue<User?>>(
      authStateProvider,
      (_, __) => notifyListeners(),
      fireImmediately: false,
    );
  }
  late final ProviderSubscription<AsyncValue<User?>> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
