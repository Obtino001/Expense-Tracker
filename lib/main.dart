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
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ---- System UI ----
  if (!kIsWeb) {
    try {
      SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
      );
    } catch (e) {
      debugPrint('System UI init failed: $e');
    }
  }

  // Initialize optional platform services asynchronously without blocking runApp
  _initServices();

  runApp(const ProviderScope(child: BudgetApp()));
}

Future<void> _initServices() async {
  final FirebaseOptions options = DefaultFirebaseOptions.currentPlatform;
  final bool isPlaceholder = options.apiKey.startsWith('REPLACE_ME');

  if (!isPlaceholder) {
    try {
      await Firebase.initializeApp(options: options);
      if (!kIsWeb) {
        FlutterError.onError =
            FirebaseCrashlytics.instance.recordFlutterFatalError;
        PlatformDispatcher.instance.onError = (Object e, StackTrace s) {
          FirebaseCrashlytics.instance.recordError(e, s, fatal: true);
          return true;
        };
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(!kDebugMode);
        await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);
      }
    } catch (e) {
      debugPrint('Firebase init error: $e');
    }
  } else {
    debugPrint('Running in demo mode with local mock storage (Firebase placeholder keys detected).');
  }

  if (!kIsWeb) {
    try {
      await NotificationService.instance.init();
    } catch (e) {
      debugPrint('NotificationService init in fallback: $e');
    }
  }
}
