import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AppBackendService {
  AppBackendService._();
  static final AppBackendService instance = AppBackendService._();

  static const String _serverClientId =
      '119149082269-6rakl7lhooe88f7a8221in3f3ienk4jl.apps.googleusercontent.com';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(serverClientId: _serverClientId);

  User? get currentUser => _auth.currentUser;
  String? get uid => currentUser?.uid;
  bool get isAnonymous => currentUser?.isAnonymous ?? false;

  /// Stream of auth state changes (null = signed out, User = signed in)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Check karo agar user already signed in hai.
  /// Agar nahi hai toh kuch nahi karta — login screen handle karegi.
  Future<void> initAuth() async {
    // Sirf check — sign in nahi karte forcefully.
    // Router auth state ke basis pe login screen pe redirect karega.
  }

  /// Sign in anonymously as a Guest user.
  Future<bool> signInAnonymously() async {
    try {
      if (currentUser != null) {
        return true;
      }
      await _auth.signInAnonymously();
      return true;
    } catch (e, stack) {
      debugPrint("Anonymous SignIn Error: $e");
      debugPrint(stack.toString());
      return false;
    }
  }

  /// Google Sign In karo.
  ///
  /// Agar user ka account deletion pending hai to [GoogleSignInResult.deletionPending]
  /// return kiya jaata hai aur user ko sign in nahi karne diya jaata.
  Future<GoogleSignInResult> signInWithGoogle() async {
    // Clear any previous sign-in session so the account picker always opens.
    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    GoogleSignInAccount? googleUser;
    try {
      googleUser = await _googleSignIn.signIn();
    } catch (e, stack) {
      debugPrint('Google SignIn (picker) Error: $e\n$stack');
      return GoogleSignInResult.failure('Google sign-in could not start: $e');
    }

    if (googleUser == null) {
      return const GoogleSignInResult.cancelled();
    }

    try {
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        const message =
            'Google sign-in returned no ID token (missing Web OAuth client / default_web_client_id).';
        debugPrint(message);
        return GoogleSignInResult.failure(message);
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      // ── Deletion-pending check (Authenticated) ───────────────────────────
      if (user != null) {
        try {
          final pendingSnap = await _firestore
              .collection('deletion_requests')
              .where('email', isEqualTo: user.email)
              .where('status', isEqualTo: 'pending')
              .limit(1)
              .get();

          if (pendingSnap.docs.isNotEmpty) {
            // Pending deletion found! Sign user out immediately.
            try {
              await _googleSignIn.signOut();
            } catch (_) {}
            await _auth.signOut();
            return const GoogleSignInResult.deletionPending();
          }
        } catch (e) {
          debugPrint('Deletion check error: $e');
        }
      }
      // ── End deletion-pending check ──────────────────────────────────────

      return const GoogleSignInResult.success();
    } on FirebaseAuthException catch (e, stack) {
      debugPrint('Google SignIn Error: code=${e.code} message=${e.message}\n$stack');
      return GoogleSignInResult.failure(
        'Firebase sign-in failed (${e.code}): ${e.message ?? 'unknown error'}',
      );
    } catch (e, stack) {
      debugPrint('Google SignIn Error: $e\n$stack');
      return GoogleSignInResult.failure('Google sign-in failed: $e');
    }
  }

  /// Links the current anonymous account with Google credentials.
  Future<LinkGoogleResult> linkWithGoogle() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const LinkGoogleResult(
          LinkGoogleStatus.error,
          'No user currently signed in',
        );
      }
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const LinkGoogleResult(LinkGoogleStatus.cancelled);
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await user.linkWithCredential(credential);
      return const LinkGoogleResult(
        LinkGoogleStatus.success,
        'Successfully linked your Google account!',
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use' ||
          e.code == 'email-already-in-use') {
        return const LinkGoogleResult(
          LinkGoogleStatus.credentialAlreadyInUse,
          'This Google account is already linked to another player. Please log out and sign in directly with Google.',
        );
      }
      return LinkGoogleResult(
        LinkGoogleStatus.error,
        e.message ?? 'Failed to link Google account',
      );
    } catch (e) {
      return LinkGoogleResult(
        LinkGoogleStatus.error,
        e.toString(),
      );
    }
  }

  /// Sign out karo.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  /// Returns the Firestore document reference for the current user.
  DocumentReference<Map<String, dynamic>>? get userDoc {
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid);
  }

  /// Returns the Firestore collection reference for the user's daily sessions.
  CollectionReference<Map<String, dynamic>>? get userSessionsCollection {
    final doc = userDoc;
    if (doc == null) return null;
    return doc.collection('daily_sessions');
  }

  /// ── 30-Day Account Deletion Request ──────────────────────────────────────
  ///
  /// User ka account foran delete nahi hota. Ek deletion request Firestore
  /// ke `deletion_requests` collection mein save hoti hai. Admin 30 days
  /// ke andar manually delete karta hai.
  ///
  /// User turant sign out ho jaata hai aur dobara is email se login nahi
  /// kar sakta jab tak admin permanently delete nahi kar deta.
  Future<DeletionRequestResult> requestAccountDeletion() async {
    final user = _auth.currentUser;
    if (user == null) {
      return DeletionRequestResult.failure('No user signed in');
    }

    final email = user.email;
    final userId = user.uid;

    try {
      await _firestore.collection('deletion_requests').add({
        'uid': userId,
        'email': email ?? '',
        'displayName': user.displayName ?? '',
        'requestedAt': FieldValue.serverTimestamp(),
        'status': 'pending', // pending | deleted
        'scheduledDeleteAt': DateTime.now()
            .add(const Duration(days: 30))
            .toIso8601String(),
      });

      // User ko sign out karo
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
      await _auth.signOut();

      return const DeletionRequestResult.success();
    } catch (e) {
      debugPrint('Deletion request error: $e');
      return DeletionRequestResult.failure(
          'Failed to submit deletion request: $e');
    }
  }

  /// Check karo k koi email deletion pending hai ya nahi.
  Future<bool> isEmailDeletionPending(String email) async {
    try {
      final snap = await _firestore
          .collection('deletion_requests')
          .where('email', isEqualTo: email)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();
      return snap.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

// ─── Enums & Result types ────────────────────────────────────────────────────

enum LinkGoogleStatus {
  success,
  cancelled,
  credentialAlreadyInUse,
  error,
}

enum GoogleSignInStatus { success, cancelled, failure, deletionPending }

class GoogleSignInResult {
  const GoogleSignInResult._(this.status, this.message);

  const GoogleSignInResult.success()
      : this._(GoogleSignInStatus.success, null);
  const GoogleSignInResult.cancelled()
      : this._(GoogleSignInStatus.cancelled, null);
  const GoogleSignInResult.deletionPending()
      : this._(GoogleSignInStatus.deletionPending, null);
  const GoogleSignInResult.failure(String message)
      : this._(GoogleSignInStatus.failure, message);

  final GoogleSignInStatus status;
  final String? message;

  bool get isSuccess => status == GoogleSignInStatus.success;
  bool get isCancelled => status == GoogleSignInStatus.cancelled;
  bool get isDeletionPending => status == GoogleSignInStatus.deletionPending;
}

class LinkGoogleResult {
  const LinkGoogleResult(this.status, [this.message]);

  final LinkGoogleStatus status;
  final String? message;

  bool get isSuccess => status == LinkGoogleStatus.success;
}

enum DeletionRequestStatus { success, failure }

class DeletionRequestResult {
  const DeletionRequestResult._(this.status, this.message);
  const DeletionRequestResult.success()
      : this._(DeletionRequestStatus.success, null);
  const DeletionRequestResult.failure(String msg)
      : this._(DeletionRequestStatus.failure, msg);

  final DeletionRequestStatus status;
  final String? message;

  bool get isSuccess => status == DeletionRequestStatus.success;
}
