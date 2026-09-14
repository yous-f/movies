import 'package:firebase_auth/firebase_auth.dart';

import 'package:movies/core/errors/api_exception.dart';
import 'package:movies/core/errors/network_exception.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  Future<void> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } on Exception {
      throw ApiException('Authentication failed');
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } on Exception {
      throw ApiException('Registration failed');
    }
  }

  Future<void> updateProfile({String? name}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw ApiException('No user currently logged in');
      }
      if (name != null && name.isNotEmpty) {
        await user.updateDisplayName(name);
      }
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } on Exception {
      throw ApiException('Failed to update profile');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _firebaseAuth.signInWithProvider(GoogleAuthProvider());
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } on Exception {
      throw ApiException('Authentication failed');
    }
  }

  Exception _mapFirebaseAuthException(FirebaseAuthException exception) =>
      mapFirebaseAuthException(exception);
}

Exception mapFirebaseAuthException(FirebaseAuthException exception) {
  switch (exception.code) {
    case 'network-request-failed':
      return NetworkException('No internet connection');
    case 'email-already-in-use':
      return ApiException('The email address is already in use');
    case 'weak-password':
      return ApiException('The password provided is too weak');
    case 'user-not-found':
      return ApiException('No account found for this email');
    case 'wrong-password':
    case 'invalid-credential':
    case 'invalid-email':
      return ApiException('Invalid email or password');
    case 'user-disabled':
      return ApiException('This account has been disabled');
    case 'too-many-requests':
      return ApiException('Too many attempts. Please try again later');
    case 'operation-not-allowed':
      return ApiException('This sign-in method is not enabled');
    case 'account-exists-with-different-credential':
      return ApiException(
        'An account already exists with a different sign-in method',
      );
    case 'canceled':
    case 'cancelled':
    case 'web-context-canceled':
    case 'web-context-cancelled':
      return ApiException('Google sign-in was cancelled');
    default:
      return ApiException(exception.message ?? 'Authentication failed');
  }
}