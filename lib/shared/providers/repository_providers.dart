import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/firestore_transaction_repository.dart';
import '../../data/repositories/firestore_user_repository.dart';
import '../../data/repositories/monthly_analytics_repository.dart';
import 'auth_provider.dart';

/// All repositories live behind providers. The Firestore-backed ones depend
/// on the current uid, so they rebuild whenever auth state changes.

final Provider<FirestoreUserRepository> userRepositoryProvider =
    Provider<FirestoreUserRepository>((Ref ref) => FirestoreUserRepository());

/// Transaction/budget/category repo — null if signed out (UI should guard).
final Provider<FirestoreTransactionRepository?>
    transactionRepositoryProvider =
    Provider<FirestoreTransactionRepository?>((Ref ref) {
  final User? user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return FirestoreTransactionRepository(uid: user.uid);
});

final Provider<MonthlyAnalyticsRepository?> monthlyAnalyticsRepositoryProvider =
    Provider<MonthlyAnalyticsRepository?>((Ref ref) {
  final User? user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return MonthlyAnalyticsRepository(uid: user.uid);
});
