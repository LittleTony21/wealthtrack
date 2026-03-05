import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/user_profile.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

class AuthNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> signInWithEmail(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUpWithEmail(
    String email,
    String password, {
    required String name,
    required String avatar,
    required String currency,
    required String theme,
    required bool pinEnabled,
    required String pinCode,
  }) async {
    final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = result.user?.uid;
    if (uid != null) {
      final profile = UserProfile(
        id: uid,
        userName: name,
        userAvatar: avatar,
        currency: currency,
        theme: theme,
        pinEnabled: pinEnabled,
        pinCode: pinCode,
      );
      final data = profile.toJson()..remove('id');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(data, SetOptions(merge: true));
    }
  }

  Future<void> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw Exception('Google sign in cancelled');
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  /// Sign-in only — rejects if no existing account found.
  Future<void> signInOnlyWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign in cancelled');
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final result = await FirebaseAuth.instance.signInWithCredential(credential);
    if (result.additionalUserInfo?.isNewUser == true) {
      await result.user?.delete();
      await googleSignIn.signOut();
      throw Exception(
          'No account found for this Google account. Please sign up first.');
    }
  }

  Future<void> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  /// Sign-in only — rejects if no existing account found.
  Future<void> signInOnlyWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    final result = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    if (result.additionalUserInfo?.isNewUser == true) {
      await result.user?.delete();
      throw Exception('No account found for this Apple ID. Please sign up first.');
    }
  }

  Future<void> sendPasswordReset(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  Future<void> deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;
    final db = FirebaseFirestore.instance;

    // Delete all assets
    final assets = await db.collection('users/$uid/assets').get();
    for (final doc in assets.docs) {
      await doc.reference.delete();
    }

    // Delete all liabilities
    final liabs = await db.collection('users/$uid/liabilities').get();
    for (final doc in liabs.docs) {
      await doc.reference.delete();
    }

    // Delete profile document
    await db.doc('users/$uid').delete();

    // Delete Firebase Auth account
    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        // Re-authenticate via Google if that was their provider
        final providerIds = user.providerData.map((p) => p.providerId).toList();
        if (providerIds.contains('google.com')) {
          final googleUser = await GoogleSignIn().signIn();
          if (googleUser != null) {
            final googleAuth = await googleUser.authentication;
            final credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );
            await user.reauthenticateWithCredential(credential);
            await user.delete();
          }
        } else {
          rethrow;
        }
      } else {
        rethrow;
      }
    }
    await GoogleSignIn().signOut();
  }
}

final authProvider = NotifierProvider<AuthNotifier, void>(() => AuthNotifier());
