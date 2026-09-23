import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'animation_constants.dart';

/// Smooth page transition builders for go_router.
/// We pass the [GoRouterState] so each page gets a unique [LocalKey].

CustomTransitionPage<void> fadeThroughPage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: AppAnimations.normal,
    reverseTransitionDuration: AppAnimations.fast,
    child: child,
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondary,
      Widget child,
    ) {
      // Fade + subtle scale — a la Material 3 fadeThrough.
      final CurvedAnimation curved = CurvedAnimation(
        parent: animation,
        curve: AppAnimations.emphasizedDecelerate,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

CustomTransitionPage<void> slideUpPage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: AppAnimations.normal,
    reverseTransitionDuration: AppAnimations.fast,
    child: child,
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondary,
      Widget child,
    ) {
      final CurvedAnimation curved = CurvedAnimation(
        parent: animation,
        curve: AppAnimations.emphasizedDecelerate,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
  );
}
