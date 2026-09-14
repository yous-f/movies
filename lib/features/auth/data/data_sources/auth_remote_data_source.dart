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
