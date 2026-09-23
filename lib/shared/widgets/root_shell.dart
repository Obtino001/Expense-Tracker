import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import 'bottom_nav_bar.dart';

/// Persistent shell that wraps the main 5 tabs matching the screenshot:
/// 1. Home
/// 2. Analytics / Insights (with Coral Squircle badge)
/// 3. Budgets
/// 4. Transactions (Clock / History)
/// 5. Profile
class RootShell extends ConsumerWidget {
  const RootShell({required this.child, super.key});

  final Widget child;

  static const List<BottomNavItem> _items = <BottomNavItem>[
    BottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    BottomNavItem(
      icon: Icons.show_chart_rounded,
      activeIcon: Icons.show_chart_rounded,
      label: 'Insights',
    ),
    BottomNavItem(
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
      label: 'Budget',
    ),
    BottomNavItem(
      icon: Icons.access_time_rounded,
      activeIcon: Icons.access_time_filled_rounded,
      label: 'Activity',
    ),
    BottomNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  static const List<String> _routes = <String>[
    RouteNames.home,
    RouteNames.analytics,
    RouteNames.budgets,
    RouteNames.transactions,
    RouteNames.profile,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int index = ref.watch(bottomTabIndexProvider);
    ref.watch(postSignInBootstrapProvider);

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: AppBottomNav(
        currentIndex: index.clamp(0, _items.length - 1),
        items: _items,
        onTap: (int i) {
          ref.read(bottomTabIndexProvider.notifier).state = i;
          context.go(_routes[i]);
        },
      ),
    );
  }
}
