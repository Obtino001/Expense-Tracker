import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/preferences_provider.dart';

class AppFeedback {
  AppFeedback._();
  static void selection(WidgetRef ref) {
    if (ref.read(preferencesProvider).hapticsEnabled) HapticFeedback.selectionClick();
  }
  static void impact(WidgetRef ref) {
    if (ref.read(preferencesProvider).hapticsEnabled) HapticFeedback.lightImpact();
  }
}
