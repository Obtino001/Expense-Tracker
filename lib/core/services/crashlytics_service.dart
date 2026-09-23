import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Convenience layer around Crashlytics for app-specific instrumentation.
class CrashlyticsService {
  CrashlyticsService._();
  static final CrashlyticsService instance = CrashlyticsService._();

  FirebaseCrashlytics? get _crash {
    if (kIsWeb) return null;
    try {
      return Firebase.apps.isNotEmpty ? FirebaseCrashlytics.instance : null;
    } catch (_) {
      return null;
    }
  }

  /// Attach the current user — appears on every subsequent crash report.
  Future<void> setUser(String? uid) async {
    try {
      await _crash?.setUserIdentifier(uid ?? 'anonymous');
    } catch (_) {}
  }

  /// Free-form key/value that shows up in the dashboard.
  Future<void> setCustomKey(String key, Object value) async {
    try {
      await _crash?.setCustomKey(key, value);
    } catch (_) {}
  }

  /// Breadcrumb-style log. Visible in the crash report's "Logs" tab.
  Future<void> log(String message) async {
    try {
      await _crash?.log(message);
    } catch (_) {}
  }

  /// Manually report a caught exception.
  Future<void> recordError(Object error, StackTrace stack,
      {bool fatal = false}) async {
    try {
      await _crash?.recordError(error, stack, fatal: fatal);
    } catch (_) {}
  }
}
