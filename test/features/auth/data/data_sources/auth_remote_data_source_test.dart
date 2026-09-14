import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movies/core/errors/api_exception.dart';
import 'package:movies/core/errors/network_exception.dart';
import 'package:movies/features/auth/data/data_sources/auth_remote_data_source.dart';

void main() {
  group('mapFirebaseAuthException', () {
    test('maps user-not-found to ApiException', () {
      final exception = FirebaseAuthException(
        code: 'user-not-found',
        message: 'There is no user record.',
      );

      final result = mapFirebaseAuthException(exception);

      expect(result, isA<ApiException>());
      expect((result as ApiException).message, 'No account found for this email');
    });

    test('maps wrong-password to ApiException', () {
      final result = mapFirebaseAuthException(
        FirebaseAuthException(code: 'wrong-password', message: 'Invalid.'),
      );

      expect(result, isA<ApiException>());
      expect((result as ApiException).message, 'Invalid email or password');
    });

    test('maps invalid-credential to ApiException', () {
      final result = mapFirebaseAuthException(
        FirebaseAuthException(code: 'invalid-credential', message: 'Bad.'),
      );

      expect(result, isA<ApiException>());
      expect((result as ApiException).message, 'Invalid email or password');
    });

    test('maps invalid-email to ApiException', () {
      final result = mapFirebaseAuthException(
        FirebaseAuthException(code: 'invalid-email', message: 'Bad format.'),
      );

      expect(result, isA<ApiException>());
      expect((result as ApiException).message, 'Invalid email or password');
    });

    test('maps user-disabled to ApiException', () {
      final result = mapFirebaseAuthException(
        FirebaseAuthException(code: 'user-disabled', message: 'Disabled.'),
      );

      expect(result, isA<ApiException>());
      expect((result as ApiException).message, 'This account has been disabled');
    });

    test('maps too-many-requests to ApiException', () {
      final result = mapFirebaseAuthException(
        FirebaseAuthException(code: 'too-many-requests', message: 'Rate limited.'),
      );

      expect(result, isA<ApiException>());
      expect(
        (result as ApiException).message,
        'Too many attempts. Please try again later',
      );
    });

    test('maps network-request-failed to NetworkException', () {
      final result = mapFirebaseAuthException(
        FirebaseAuthException(code: 'network-request-failed', message: 'Network error.'),
      );

      expect(result, isA<NetworkException>());
      expect((result as NetworkException).message, 'No internet connection');
    });

    test('maps operation-not-allowed to ApiException', () {
      final result = mapFirebaseAuthException(
        FirebaseAuthException(code: 'operation-not-allowed', message: 'Not allowed.'),
      );

      expect(result, isA<ApiException>());
      expect(
        (result as ApiException).message,
        'This sign-in method is not enabled',
      );
    });

    test('maps account-exists-with-different-credential to ApiException', () {
      final result = mapFirebaseAuthException(
        FirebaseAuthException(
          code: 'account-exists-with-different-credential',
          message: 'Exists.',
        ),
      );

      expect(result, isA<ApiException>());
      expect(
        (result as ApiException).message,
        'An account already exists with a different sign-in method',
      );
    });

    test('maps cancelled to ApiException', () {
      final result = mapFirebaseAuthException(
        FirebaseAuthException(code: 'cancelled', message: 'Cancelled.'),
      );

      expect(result, isA<ApiException>());
      expect((result as ApiException).message, 'Google sign-in was cancelled');
    });

    test('maps canceled to ApiException', () {
      final result = mapFirebaseAuthException(
        FirebaseAuthException(code: 'canceled', message: 'Canceled.'),
      );

      expect(result, isA<ApiException>());
      expect((result as ApiException).message, 'Google sign-in was cancelled');
    });

    test('maps web-context-canceled to ApiException', () {
      final result = mapFirebaseAuthException(
        FirebaseAuthException(code: 'web-context-canceled', message: 'Closed.'),
      );

      expect(result, isA<ApiException>());
      expect((result as ApiException).message, 'Google sign-in was cancelled');
    });

    test('maps web-context-cancelled to ApiException', () {
      final result = mapFirebaseAuthException(
        FirebaseAuthException(code: 'web-context-cancelled', message: 'Closed.'),
      );

      expect(result, isA<ApiException>());
      expect((result as ApiException).message, 'Google sign-in was cancelled');
    });

    test('maps unknown code to ApiException with Firebase message', () {
      final result = mapFirebaseAuthException(
        FirebaseAuthException(code: 'unknown-code', message: 'Something happened.'),
      );

      expect(result, isA<ApiException>());
      expect((result as ApiException).message, 'Something happened.');
    });

    test('maps unknown code with null message to generic fallback', () {
      final result = mapFirebaseAuthException(
        FirebaseAuthException(code: 'unknown-code'),
      );

      expect(result, isA<ApiException>());
      expect((result as ApiException).message, 'Authentication failed');
    });
  });
}
