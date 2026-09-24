import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/animations/animation_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import 'bottom_nav_bar.dart';

/// Persistent shell that wraps the main 5 tabs matching the screenshot:
/// 1. Home
/// 2. Analytics / Insights (with Coral Squircle badge)
/// 3. Budgets
/// 4. Transactions (Clock / History)
/// 5. Profile
class RootShell extends ConsumerStatefulWidget {
  const RootShell({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<RootShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: Motion.base,
    value: 1,
  );

  @override
  void didUpdateWidget(RootShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child && !Motion.reduced(context)) {
      _fade.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    final int index = ref.watch(bottomTabIndexProvider);
    ref.watch(postSignInBootstrapProvider);

    return Scaffold(
      extendBody: true,
      body: Motion.reduced(context)
          ? widget.child
          : AnimatedBuilder(
              animation: _fade,
              child: widget.child,
              builder: (context, child) => Opacity(
                opacity: Motion.out.transform(_fade.value),
                child: Transform.translate(
                  offset:
                      Offset(0, 8 * (1 - Motion.out.transform(_fade.value))),
                  child: child,
                ),
              ),
            ),
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
