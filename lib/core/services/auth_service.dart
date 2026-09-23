import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// Thin wrapper around [FirebaseAuth]. Keeps the rest of the app
/// decoupled from the Firebase SDK and makes it trivial to mock in tests.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _customAuth = auth;

  final FirebaseAuth? _customAuth;

  FirebaseAuth? get _auth {
    if (_customAuth != null) return _customAuth;
    try {
      return Firebase.apps.isNotEmpty ? FirebaseAuth.instance : null;
    } catch (_) {
      return null;
    }
  }

  /// Current logged-in user, or null if signed out.
  User? get currentUser => _auth?.currentUser;

  /// Emits a new value every time the auth state changes (sign in/out).
  /// Used by the router redirect and the splash screen.
  Stream<User?> authStateChanges() {
    final FirebaseAuth? a = _auth;
    return a != null ? a.authStateChanges() : Stream<User?>.value(null);
  }

  // ---------- Sign-in ----------
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    final FirebaseAuth? a = _auth;
    if (a == null) {
      throw Exception('Firebase is not configured.');
    }
    return a.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final FirebaseAuth? a = _auth;
    if (a == null) {
      throw Exception('Firebase is not configured.');
    }
    final UserCredential cred = await a.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    // Set the Auth display name so the profile starts populated.
    await cred.user?.updateDisplayName(displayName);
    return cred;
  }

  Future<void> sendPasswordReset(String email) {
    final FirebaseAuth? a = _auth;
    if (a == null) {
      throw Exception('Firebase is not configured.');
    }
    return a.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    final FirebaseAuth? a = _auth;
    if (a != null) await a.signOut();
  }

  /// Anonymous sign-in for first-launch onboarding without forcing auth.
  /// Can later be linked to email/password via [User.linkWithCredential].
  Future<UserCredential> signInAnonymously() {
    final FirebaseAuth? a = _auth;
    if (a == null) {
      throw Exception('Firebase is not configured.');
    }
    return a.signInAnonymously();
  }
}
