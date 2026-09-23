import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around [FirebaseAuth]. Keeps the rest of the app
/// decoupled from the Firebase SDK and makes it trivial to mock in tests.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// Current logged-in user, or null if signed out.
  User? get currentUser => _auth.currentUser;

  /// Emits a new value every time the auth state changes (sign in/out).
  /// Used by the router redirect and the splash screen.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // ---------- Sign-in ----------
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    // Set the Auth display name so the profile starts populated.
    await cred.user?.updateDisplayName(displayName);
    return cred;
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> signOut() => _auth.signOut();

  /// Anonymous sign-in for first-launch onboarding without forcing auth.
  /// Can later be linked to email/password via [User.linkWithCredential].
  Future<UserCredential> signInAnonymously() => _auth.signInAnonymously();
}
