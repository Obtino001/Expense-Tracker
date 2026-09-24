import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'animation_constants.dart';

CustomTransitionPage<void> fadeThroughPage(Widget child, GoRouterState state) =>
    _motionPage(child, state);

CustomTransitionPage<void> slideUpPage(Widget child, GoRouterState state) =>
    _motionPage(child, state);

CustomTransitionPage<void> _motionPage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: Motion.slow,
    reverseTransitionDuration: Motion.base,
    child: child,
    transitionsBuilder: (context, animation, secondary, child) {
      if (Motion.reduced(context)) return child;
      final incoming = CurvedAnimation(
          parent: animation,
          curve: Motion.emphasized,
          reverseCurve: Curves.easeIn);
      final outgoing = CurvedAnimation(
          parent: secondary, curve: Motion.out, reverseCurve: Curves.easeIn);
      return FadeTransition(
        opacity: outgoing.drive(Tween<double>(begin: 1, end: .92)),
        child: FadeTransition(
          opacity: incoming,
          child: SlideTransition(
            position: incoming.drive(
                Tween<Offset>(begin: const Offset(0, .025), end: Offset.zero)),
            child: child,
          ),
        ),
      );
    },
  );
}
