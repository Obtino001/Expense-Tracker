// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:budget_app/app.dart';
import 'package:budget_app/core/theme/app_theme.dart';

void main() {
  AppTheme.useGoogleFonts = false;
  testWidgets('App root smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: BudgetApp(),
        ),
      ),
    );
    expect(find.byType(BudgetApp), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
