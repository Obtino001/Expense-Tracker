import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/services/notification_service.dart';
import 'firebase_options.dart';

/// FCM background handler MUST be a top-level function.
/// Triggered when the app is fully terminated and a push arrives.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase here — the isolate is fresh.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // No UI work here; the OS shows the notification.
}

Future<void> main() async {
  // `runZonedGuarded` lets Crashlytics catch async errors that escape Flutter.
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // ---- System UI ----
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    // ---- Firebase (Safe initialization for web / demo mode) ----
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (Object e, StackTrace s) {
        FirebaseCrashlytics.instance.recordError(e, s, fatal: true);
        return true;
      };
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);
      }
    } catch (e) {
      debugPrint('Firebase initialized in fallback/demo mode: $e');
    }

    // Init local notifications channel
    try {
      await NotificationService.instance.init();
    } catch (e) {
      debugPrint('NotificationService init in fallback: $e');
    }

    runApp(const ProviderScope(child: BudgetApp()));
  }, (Object e, StackTrace s) {
    FirebaseCrashlytics.instance.recordError(e, s, fatal: true);
  });
}
