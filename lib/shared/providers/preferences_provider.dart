import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class AppPreferences {
  const AppPreferences({
    this.currencyCode = 'USD',
    this.accent = 'mint',
    this.textScale = 1,
    this.reducedMotion = false,
    this.hapticsEnabled = true,
    this.notificationsEnabled = true,
    this.profileName = '',
    this.profileEmail = '',
    this.readNotifications = const [],
    this.dismissedNotifications = const [],
  });

  static const currencies = ['USD', 'EUR', 'GBP', 'PKR', 'AED', 'INR', 'CAD', 'AUD'];
  final String currencyCode;
  final String accent;
  final double textScale;
  final bool reducedMotion;
  final bool hapticsEnabled;
  final bool notificationsEnabled;
  final String profileName;
  final String profileEmail;
  final List<String> readNotifications;
  final List<String> dismissedNotifications;

  AppPreferences copyWith({String? currencyCode, String? accent, double? textScale,
    bool? reducedMotion, bool? hapticsEnabled, bool? notificationsEnabled,
    String? profileName, String? profileEmail, List<String>? readNotifications,
    List<String>? dismissedNotifications}) => AppPreferences(
      currencyCode: currencyCode ?? this.currencyCode,
      accent: accent ?? this.accent,
      textScale: textScale ?? this.textScale,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      profileName: profileName ?? this.profileName,
      profileEmail: profileEmail ?? this.profileEmail,
      readNotifications: readNotifications ?? this.readNotifications,
      dismissedNotifications: dismissedNotifications ?? this.dismissedNotifications,
    );
}

class PreferencesNotifier extends StateNotifier<AppPreferences> {
  PreferencesNotifier() : super(const AppPreferences()) { ready = _restore(); }
  late final Future<void> ready;
  late SharedPreferences _storage;

  Future<void> _restore() async {
    _storage = await SharedPreferences.getInstance();
    final currency = _storage.getString('budget.currency') ?? 'USD';
    final accent = _storage.getString('budget.accent') ?? 'mint';
    final scale = _storage.getDouble('budget.textScale') ?? 1;
    if (!mounted) return;
    state = AppPreferences(
      currencyCode: AppPreferences.currencies.contains(currency) ? currency : 'USD',
      accent: ['mint', 'blue', 'violet'].contains(accent) ? accent : 'mint',
      textScale: [1.0, 1.15, 1.3].contains(scale) ? scale : 1,
      reducedMotion: _storage.getBool('budget.reducedMotion') ?? false,
      hapticsEnabled: _storage.getBool('budget.haptics') ?? true,
      notificationsEnabled: _storage.getBool('budget.notifications') ?? true,
      profileName: _storage.getString('budget.profileName') ?? '',
      profileEmail: _storage.getString('budget.profileEmail') ?? '',
      readNotifications: _storage.getStringList('budget.readNotifications') ?? [],
      dismissedNotifications: _storage.getStringList('budget.dismissedNotifications') ?? [],
    );
  }

  Future<void> setCurrency(String value) async {
    if (!AppPreferences.currencies.contains(value)) return;
    await ready;
    state = state.copyWith(currencyCode: value);
    await _storage.setString('budget.currency', value);
  }
  Future<void> setAccent(String value) async {
    if (!['mint', 'blue', 'violet'].contains(value)) return;
    await ready;
    state = state.copyWith(accent: value);
    await _storage.setString('budget.accent', value);
  }
  Future<void> setTextScale(double value) async {
    if (![1.0, 1.15, 1.3].contains(value)) return;
    await ready;
    state = state.copyWith(textScale: value);
    await _storage.setDouble('budget.textScale', value);
  }
  Future<void> setReducedMotion(bool value) async {
    await ready;
    state = state.copyWith(reducedMotion: value);
    await _storage.setBool('budget.reducedMotion', value);
  }
  Future<void> setHaptics(bool value) async {
    await ready;
    state = state.copyWith(hapticsEnabled: value);
    await _storage.setBool('budget.haptics', value);
    if (value) await selectionFeedback();
  }
  Future<void> setNotifications(bool value) async {
    await ready;
    state = state.copyWith(notificationsEnabled: value);
    await _storage.setBool('budget.notifications', value);
  }
  Future<void> saveProfile({required String name, required String email}) async {
    await ready;
    state = state.copyWith(profileName: name.trim(), profileEmail: email.trim());
    await _storage.setString('budget.profileName', state.profileName);
    await _storage.setString('budget.profileEmail', state.profileEmail);
  }
  Future<void> markNotificationsRead(Iterable<String> ids) async {
    await ready;
    final values = {...state.readNotifications, ...ids}.toList();
    state = state.copyWith(readNotifications: values);
    await _storage.setStringList('budget.readNotifications', values);
  }
  Future<void> dismissNotification(String id) async {
    await ready;
    final values = {...state.dismissedNotifications, id}.toList();
    state = state.copyWith(dismissedNotifications: values);
    await _storage.setStringList('budget.dismissedNotifications', values);
  }
  Future<void> restoreNotification(String id) async {
    await ready;
    final values = state.dismissedNotifications.where((value) => value != id).toList();
    state = state.copyWith(dismissedNotifications: values);
    await _storage.setStringList('budget.dismissedNotifications', values);
  }
  Future<void> selectionFeedback() async {
    if (state.hapticsEnabled && !kIsWeb) await HapticFeedback.selectionClick();
  }
}

final preferencesProvider = StateNotifierProvider<PreferencesNotifier, AppPreferences>(
  (ref) => PreferencesNotifier(),
);
