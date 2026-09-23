import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) { ready = _restore(); }
  late final Future<void> ready;

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('budget.theme');
    if (mounted) {
      state = ThemeMode.values.firstWhere((m) => m.name == saved,
          orElse: () => ThemeMode.system);
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    await ready;
    if (!mounted) return;
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('budget.theme', mode.name);
  }

  Future<void> toggle() =>
      setMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);
