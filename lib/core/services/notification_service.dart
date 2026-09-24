import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Push notifications.
///
/// Responsibilities:
/// 1. Ask the user for permission (iOS / Android 13+).
/// 2. Register the device's FCM token in Firestore (`users/{uid}.fcmTokens`).
/// 3. Convert foreground RemoteMessages into local notifications so they
///    actually appear (FCM doesn't auto-display when the app is in foreground).
///
/// Wire-up is done in [main.dart] (background handler) and at sign-in
/// (token registration via the user repository).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  FirebaseMessaging? get _fcm {
    if (kIsWeb) return null;
    try {
      return Firebase.apps.isNotEmpty ? FirebaseMessaging.instance : null;
    } catch (_) {
      return null;
    }
  }

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const String _androidChannelId = 'budget_default';
  static const String _androidChannelName = 'Budget notifications';

  bool _initialized = false;

  /// Call once during app start (in `main`).
  Future<void> init() async {
    if (kIsWeb) return;
    if (_initialized) return;
    _initialized = true;

    // ---- Local notifications (Android channel + iOS settings) ----
    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings ios = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Create the channel (required on Android 8+).
    final AndroidFlutterLocalNotificationsPlugin? androidImpl =
        _local.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName,
        description: 'Budget alerts, bills, insights',
        importance: Importance.high,
      ),
    );

    // ---- FCM listeners ----
    if (_fcm != null) {
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    }
  }

  /// Prompt permission and return whether the user granted it.
  /// Call this AFTER sign-in so the prompt has a context.
  Future<bool> requestPermission() async {
    if (kIsWeb || _fcm == null) return false;
    final NotificationSettings s = await _fcm!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return s.authorizationStatus == AuthorizationStatus.authorized ||
        s.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Returns the device's FCM token. Persist this in Firestore so Cloud
  /// Functions can target this user.
  Future<String?> getToken() async {
    if (kIsWeb || _fcm == null) return null;
    // APNs token must be available on iOS before requesting an FCM token.
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      await _fcm!.getAPNSToken();
    }
    return _fcm!.getToken();
  }

  /// Listens for token rotation events (rare but real).
  Stream<String> onTokenRefresh() =>
      _fcm != null ? _fcm!.onTokenRefresh : const Stream<String>.empty();

  /// Display a foreground push as a local heads-up notification.
  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final RemoteNotification? n = message.notification;
    if (n == null) return;
    await _local.show(
      n.hashCode,
      n.title,
      n.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data.toString(),
    );
    if (kDebugMode) {
      debugPrint('FCM foreground: ${n.title} — ${n.body}');
    }
  }
}
