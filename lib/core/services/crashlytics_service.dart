import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Convenience layer around Crashlytics for app-specific instrumentation.
class CrashlyticsService {
  CrashlyticsService._();
  static final CrashlyticsService instance = CrashlyticsService._();

  final FirebaseCrashlytics _crash = FirebaseCrashlytics.instance;

  /// Attach the current user — appears on every subsequent crash report.
  Future<void> setUser(String? uid) =>
      _crash.setUserIdentifier(uid ?? 'anonymous');

  /// Free-form key/value that shows up in the dashboard.
  Future<void> setCustomKey(String key, Object value) =>
      _crash.setCustomKey(key, value);

  /// Breadcrumb-style log. Visible in the crash report's "Logs" tab.
  Future<void> log(String message) => _crash.log(message);

  /// Manually report a caught exception.
  Future<void> recordError(Object error, StackTrace stack,
          {bool fatal = false}) =>
      _crash.recordError(error, stack, fatal: fatal);
}
