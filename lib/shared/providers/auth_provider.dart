import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/analytics_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/crashlytics_service.dart';
import '../../core/services/notification_service.dart';
import '../../data/mock/mock_data.dart';
import '../../data/repositories/firestore_transaction_repository.dart';
import '../../data/repositories/firestore_user_repository.dart';

final Provider<AuthService> authServiceProvider =
    Provider<AuthService>((Ref ref) => AuthService());

/// Reactively follows FirebaseAuth.authStateChanges.
/// Drives the GoRouter redirect + everything keyed off `currentUserProvider`.
final StreamProvider<User?> authStateProvider = StreamProvider<User?>(
  (Ref ref) => ref.watch(authServiceProvider).authStateChanges(),
);

/// Sync accessor — null if not signed in.
final Provider<User?> currentUserProvider = Provider<User?>((Ref ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

/// Side-effects that should run exactly once when a user signs in:
/// ensure profile doc, register FCM token, attach analytics + crashlytics IDs.
final FutureProvider<void> postSignInBootstrapProvider =
    FutureProvider<void>((Ref ref) async {
  final User? user = ref.watch(currentUserProvider);
  if (user == null) return;

  // 1. Ensure /users/{uid} exists.
  final FirestoreUserRepository userRepo = FirestoreUserRepository();
  await userRepo.ensureProfile(user);

  // 1b. Seed default categories so the Add Transaction picker isn't empty.
  // The repo's `seedDefaultCategories` is idempotent via SetOptions(merge: true).
  await FirestoreTransactionRepository(uid: user.uid)
      .seedDefaultCategories(MockData.categories);

  // 2. Tag analytics + crashlytics with the uid.
  await AnalyticsService.instance.setUser(user.uid);
  await CrashlyticsService.instance.setUser(user.uid);

  // 3. Ask for notification permission, then persist the FCM token.
  final bool granted =
      await NotificationService.instance.requestPermission();
  if (granted) {
    final String? token = await NotificationService.instance.getToken();
    if (token != null) {
      await userRepo.addFcmToken(user.uid, token);
    }
    // Refresh listener so rotated tokens never go stale.
    NotificationService.instance.onTokenRefresh().listen((String t) {
      userRepo.addFcmToken(user.uid, t);
    });
  }
});
