import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../firebase/firestore_paths.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';

/// Manages the `users/{uid}` profile document and `users/{uid}/notifications/*`.
class FirestoreUserRepository {
  FirestoreUserRepository({FirebaseFirestore? db}) : _customDb = db;

  final FirebaseFirestore? _customDb;
  FirebaseFirestore get _db => _customDb ?? FirebaseFirestore.instance;

  // ---------- Profile ----------

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.doc(FirestorePaths.user(uid));

  Stream<UserModel?> watchUser(String uid) {
    return _userDoc(uid).snapshots().map(
          (DocumentSnapshot<Map<String, dynamic>> s) =>
              s.exists ? UserModel.fromJson(s.data()!) : null,
        );
  }

  Future<UserModel?> getUser(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> s = await _userDoc(uid).get();
    return s.exists ? UserModel.fromJson(s.data()!) : null;
  }

  /// Create the profile doc if it doesn't exist. Called once after signup.
  Future<UserModel> ensureProfile(User user) async {
    final DocumentReference<Map<String, dynamic>> ref = _userDoc(user.uid);
    final DocumentSnapshot<Map<String, dynamic>> snap = await ref.get();
    if (snap.exists) return UserModel.fromJson(snap.data()!);

    final UserModel profile = UserModel(
      id: user.uid,
      name: user.displayName ?? user.email?.split('@').first ?? 'User',
      email: user.email ?? '',
      avatarUrl: user.photoURL,
    );
    await ref.set(profile.toJson());
    return profile;
  }

  Future<void> updateProfile(
      String uid, Map<String, dynamic> fields) =>
      _userDoc(uid).update(fields);

  // ---------- FCM tokens ----------

  /// Atomic union — safe across multiple devices.
  Future<void> addFcmToken(String uid, String token) {
    return _userDoc(uid).set(
      <String, dynamic>{
        'fcmTokens': FieldValue.arrayUnion(<String>[token]),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> removeFcmToken(String uid, String token) {
    return _userDoc(uid).update(<String, dynamic>{
      'fcmTokens': FieldValue.arrayRemove(<String>[token]),
    });
  }

  // ---------- Notifications ----------

  CollectionReference<NotificationModel> _notifCol(String uid) => _db
      .collection(FirestorePaths.userNotifications(uid))
      .withConverter<NotificationModel>(
        fromFirestore: (DocumentSnapshot<Map<String, dynamic>> s, _) =>
            NotificationModel.fromJson(s.data()!),
        toFirestore: (NotificationModel n, _) => n.toJson(),
      );

  Stream<List<NotificationModel>> watchNotifications(String uid) {
    return _notifCol(uid)
        .orderBy('time', descending: true)
        .limit(50)
        .snapshots()
        .map((QuerySnapshot<NotificationModel> s) => s.docs
            .map((QueryDocumentSnapshot<NotificationModel> d) => d.data())
            .toList());
  }

  Future<void> markRead(String uid, String id) =>
      _notifCol(uid).doc(id).update(<String, dynamic>{'isRead': true});
}
