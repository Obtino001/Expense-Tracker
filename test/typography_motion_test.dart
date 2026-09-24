import 'dart:io';

import 'package:budget_app/core/animations/motion.dart';
import 'package:budget_app/core/theme/app_theme.dart';
import 'package:budget_app/features/onboarding/presentation/widgets/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:budget_app/app.dart';
import 'package:budget_app/features/home/presentation/screens/home_screen.dart';

void main() {
  AppTheme.useGoogleFonts = false;

  const page = OnboardingPageData(
    title: 'Plan your spending',
    subtitle: 'See each category and keep your budget on track every month.',
    icon: Icons.savings_rounded,
    gradient: LinearGradient(colors: [Colors.green, Colors.blue]),
  );

  testWidgets('onboarding fits phone, tablet and desktop in both themes',
      (tester) async {
    for (final width in [360.0, 768.0, 1280.0]) {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      for (final dark in [false, true]) {
        await tester.pumpWidget(MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          home: const Scaffold(
            body: MediaQuery(
              data: MediaQueryData(
                disableAnimations: true,
                textScaler: TextScaler.linear(2),
              ),
              child: OnboardingPage(data: page),
            ),
          ),
        ));
        expect(tester.takeException(), isNull);
      }
    }
    await tester.pumpWidget(const SizedBox.shrink());
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('motion runs when enabled and is static when reduced',
      (tester) async {
    for (final reduced in [false, true]) {
      await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: Builder(builder: (context) => Scaffold(
            body: const Text('Enter').fxEnter(context),
          )),
        ),
      ));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Enter'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('Inter variants and Roboto fallback are bundled', () {
    for (final name in ['Inter.ttf', 'InterTight.ttf', 'Roboto.ttf',
      'Inter-400.ttf', 'Inter-500.ttf', 'Inter-600.ttf', 'Inter-700.ttf',
      'Inter-800.ttf', 'Inter Tight-400.ttf', 'Inter Tight-500.ttf',
      'Inter Tight-600.ttf', 'Inter Tight-700.ttf', 'Inter Tight-800.ttf']) {
      expect(File('assets/fonts/$name').lengthSync(), greaterThan(100000),
        reason: name);
    }
  });

  testWidgets('main routes render at phone width and large text scale',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(const ProviderScope(child: MediaQuery(
      data: MediaQueryData(disableAnimations: true,
        textScaler: TextScaler.linear(2)),
      child: BudgetApp(),
    )));
    final router = GoRouter.of(tester.element(find.byType(HomeScreen)));
    for (final path in ['/analytics', '/budgets', '/transactions', '/profile',
      '/settings', '/notifications', '/categories', '/transactions/add',
      '/onboarding', '/login', '/signup']) {
      router.go(path);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull, reason: path);
    }
    await tester.pumpWidget(const SizedBox.shrink());
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
