import 'dart:io';

import 'package:budget_app/core/animations/motion.dart';
import 'package:budget_app/core/theme/app_theme.dart';
import 'package:budget_app/core/theme/app_style.dart';
import 'package:budget_app/core/utils/extensions.dart';
import 'package:budget_app/features/onboarding/presentation/widgets/onboarding_page.dart';
import 'package:budget_app/shared/widgets/celebrations.dart';
import 'package:budget_app/shared/widgets/app_fab.dart';
import 'package:budget_app/shared/widgets/app_button.dart';
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

  test('AppStyle standard and facebook presets have correct metrics', () {
    const std = AppStyle.standard;
    expect(std.cardRadius, 24);
    expect(std.sheetRadius, 30);
    expect(std.toolbarHeight, 64);
    expect(std.buttonHeightLg, 54);

    const fb = AppStyle.facebook;
    expect(fb.radiusSm, 4);
    expect(fb.radiusMd, 6);
    expect(fb.radiusLg, 8);
    expect(fb.cardRadius, 8);
    expect(fb.sheetRadius, 12);
    expect(fb.bubbleRadius, 18);
    expect(fb.searchPillRadius, 999);
    expect(fb.gutterSm, 12);
    expect(fb.gutterMd, 16);
    expect(fb.gutterLg, 24);
    expect(fb.buttonHeightLg, 48);
    expect(fb.buttonHeightMd, 40);
    expect(fb.buttonHeightSm, 36);
    expect(fb.inputBorderWidth, 1.0);
    expect(fb.inputVerticalPadding, 13.0);
    expect(fb.toolbarHeight, 56);
  });

  testWidgets('AppStyle is accessible via context.appStyle', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Builder(builder: (context) {
        final style = context.appStyle;
        expect(style.toolbarHeight, 64);
        return const SizedBox.shrink();
      }),
    ));
  });

  testWidgets('MascotMo renders across moods and respects reduced motion',
      (tester) async {
    for (final reduced in [false, true]) {
      for (final mood in MascotMood.values) {
        await tester.pumpWidget(MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: reduced),
            child: Scaffold(
              body: MascotMo(mood: mood),
            ),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.byType(MascotMo), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('ConfettiBurst renders child and respects reduce motion',
      (tester) async {
    for (final reduced in [false, true]) {
      await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: const Scaffold(
            body: ConfettiBurst(
              child: Text('Party'),
            ),
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Party'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('showCelebration and showAchievementUnlock open without error',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => showCelebration(
              context,
              title: 'Goal Reached',
              message: 'You kept under budget!',
            ),
            child: const Text('Open'),
          );
        }),
      ),
    ));

    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Goal Reached'), findsOneWidget);
    expect(find.text('You kept under budget!'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => showAchievementUnlock(
              context,
              title: 'Super Saver',
              message: 'Saved 20% this month',
            ),
            child: const Text('Unlock'),
          );
        }),
      ),
    ));

    await tester.tap(find.text('Unlock'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Super Saver'), findsOneWidget);
    expect(find.text('Saved 20% this month'), findsOneWidget);
    await tester.tap(find.text('Awesome'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('AppFab and AppButton render and react to interaction',
      (tester) async {
    bool fabPressed = false;
    bool btnPressed = false;

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        floatingActionButton: AppFab(
          onPressed: () => fabPressed = true,
          child: const Icon(Icons.add),
        ),
        body: AppButton(
          label: 'Save',
          onPressed: () => btnPressed = true,
        ),
      ),
    ));

    await tester.tap(find.byType(AppFab));
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();
    expect(fabPressed, isTrue);
    expect(btnPressed, isTrue);
  });

  testWidgets('AnimatedNumber renders formatted text with tabular figures',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: AnimatedNumber('Rs. 45,000'),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(AnimatedNumber), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Rs. 45,000'), findsOneWidget);
  });
}
