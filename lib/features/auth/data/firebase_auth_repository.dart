import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:point_rivals/core/firebase/firebase_contracts.dart';
import 'package:point_rivals/core/firebase/firestore_paths.dart';
import 'package:point_rivals/features/profile/data/mappers/user_profile_mapper.dart';
import 'package:point_rivals/features/profile/domain/profile_models.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  static Future<void>? _googleInitialization;
  static const String _googleServerClientId =
      '31159783168-meksoh49gs6hrrus5jomcll3qh51m0no.apps.googleusercontent.com';

  @override
  Stream<UserProfile?> authStateChanges() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) {
        return Stream.value(null);
      }

      return _watchUserProfile(user);
    });
  }

  @override
  Future<UserProfile> signInWithApple() async {
    final rawNonce = generateNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();
    final appleCredential =
        await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          nonce: hashedNonce,
        ).onError<SignInWithAppleAuthorizationException>((error, stackTrace) {
          if (error.code == AuthorizationErrorCode.canceled) {
            throw const AuthCancelledException();
          }

          throw error;
        });
    final identityToken = appleCredential.identityToken;
    if (identityToken == null || identityToken.isEmpty) {
      throw StateError('Apple sign-in completed without an identity token.');
    }
    assert(() {
      _debugPrintAppleTokenClaims(
        identityToken: identityToken,
        expectedNonce: hashedNonce,
      );
      return true;
    }());

    final credential = AppleAuthProvider.credentialWithIDToken(
      identityToken,
      rawNonce,
      AppleFullPersonName(
        givenName: appleCredential.givenName,
        familyName: appleCredential.familyName,
      ),
    );
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) {
      throw StateError('Apple sign-in completed without a Firebase user.');
    }

    return _ensureUserProfile(user);
  }

  @override
  Future<UserProfile> signInWithGoogle() async {
    _googleInitialization ??= _googleSignIn.initialize(
      serverClientId: _googleServerClientId,
    );
    await _googleInitialization;

    final googleAccount = await _googleSignIn
        .authenticate()
        .onError<GoogleSignInException>((error, stackTrace) {
          if (error.code == GoogleSignInExceptionCode.canceled ||
              error.code == GoogleSignInExceptionCode.interrupted) {
            throw const AuthCancelledException();
          }

          throw error;
        });
    final googleAuthentication = googleAccount.authentication;
    final idToken = googleAuthentication.idToken;
    if (idToken == null) {
      throw StateError('Google sign-in completed without an ID token.');
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) {
      throw StateError('Google sign-in completed without a Firebase user.');
    }

    return _ensureUserProfile(user);
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  @override
  Future<void> softDeleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    await _userDocument(user.uid).set({
      FirestoreFields.isActive: false,
      FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await signOut();
  }

  @override
  Future<void> updateProfile({
    required String displayName,
    required String? avatarUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User is not signed in.');
    }

    await user.updateDisplayName(displayName.trim());
    await _userDocument(user.uid).set({
      'displayName': displayName.trim(),
      'avatarUrl': avatarUrl,
      FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await _syncMembershipProfiles(
      userId: user.uid,
      displayName: displayName.trim(),
      avatarUrl: avatarUrl,
    );
  }

  Future<UserProfile> _ensureUserProfile(User user) async {
    final document = _userDocument(user.uid);
    final snapshot = await document.get();
    if (!snapshot.exists) {
      await document.set(
        UserProfileMapper.newUserFirestoreData(
          displayName: user.displayName ?? '',
          avatarUrl: user.photoURL,
        ),
      );
      final createdSnapshot = await document.get();
      return UserProfileMapper.fromFirestore(
        id: createdSnapshot.id,
        data: createdSnapshot.data() ?? const {},
      );
    }

    return UserProfileMapper.fromFirestore(
      id: snapshot.id,
      data: snapshot.data() ?? const {},
    );
  }

  Stream<UserProfile> _watchUserProfile(User user) async* {
    await _ensureUserProfile(user);
    await for (final snapshot in _userDocument(user.uid).snapshots()) {
      if (!snapshot.exists) {
        yield await _ensureUserProfile(user);
        continue;
      }

      yield UserProfileMapper.fromFirestore(
        id: snapshot.id,
        data: snapshot.data() ?? const {},
      );
    }
  }

  DocumentReference<Map<String, dynamic>> _userDocument(String userId) {
    return _firestore.collection(FirestoreCollections.users).doc(userId);
  }

  Future<void> _syncMembershipProfiles({
    required String userId,
    required String displayName,
    required String? avatarUrl,
  }) async {
    final memberships = await _firestore
        .collectionGroup(FirestoreCollections.members)
        .where('userId', isEqualTo: userId)
        .get();
    if (memberships.docs.isEmpty) {
      return;
    }

    final batch = _firestore.batch();
    for (final membership in memberships.docs) {
      batch.update(membership.reference, {
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  static void _debugPrintAppleTokenClaims({
    required String identityToken,
    required String expectedNonce,
  }) {
    final parts = identityToken.split('.');
    if (parts.length < 2) {
      return;
    }

    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final claims = jsonDecode(payload) as Map<String, dynamic>;
      final nonce = claims['nonce'];
      // Do not print the token or email. These fields are enough to diagnose
      // Firebase Apple provider/audience/nonce issues in debug logs.
      // ignore: avoid_print
      print(
        'Apple token claims: aud=${claims['aud']}, iss=${claims['iss']}, '
        'nonceMatches=${nonce == expectedNonce}, exp=${claims['exp']}',
      );
    } on Object {
      return;
    }
  }
}
