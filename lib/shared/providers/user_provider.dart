import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/notification_model.dart';
import '../../data/models/user_model.dart';
import 'auth_provider.dart';
import 'repository_providers.dart';

/// Real-time profile stream for the signed-in user.
final StreamProvider<UserModel?> userProvider = StreamProvider<UserModel?>(
  (Ref ref) {
    final User? user = ref.watch(currentUserProvider);
    if (user == null) return Stream<UserModel?>.value(null);
    return ref.watch(userRepositoryProvider).watchUser(user.uid);
  },
);

/// Live notifications feed — paged to the most recent 50 in the repo.
final StreamProvider<List<NotificationModel>> notificationsProvider =
    StreamProvider<List<NotificationModel>>((Ref ref) {
  final User? user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream<List<NotificationModel>>.value(const <NotificationModel>[]);
  }
  return ref.watch(userRepositoryProvider).watchNotifications(user.uid);
});

/// Bottom-tab index for the root shell.
final StateProvider<int> bottomTabIndexProvider =
    StateProvider<int>((Ref ref) => 0);
