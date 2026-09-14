import 'package:flutter_test/flutter_test.dart';

import 'package:movies/core/errors/api_exception.dart';
import 'package:movies/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:movies/features/auth/data/repositories/auth_repository_impl.dart';

class _FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  int loginCalls = 0;
  int googleCalls = 0;
  Object? loginError;
  Object? googleError;
  String? lastEmail;
  String? lastPassword;

  @override
  Future<void> login(String email, String password) async {
    loginCalls++;
    lastEmail = email;
    lastPassword = password;
    if (loginError != null) {
      throw loginError!;
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    googleCalls++;
    if (googleError != null) {
      throw googleError!;
    }
  }
}

void main() {
  late _FakeAuthRemoteDataSource fakeDataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    fakeDataSource = _FakeAuthRemoteDataSource();
    repository = AuthRepositoryImpl(fakeDataSource);
  });

  group('login', () {
    test('delegates to AuthRemoteDataSource.login', () async {
      await repository.login('user@example.com', 'password123');

      expect(fakeDataSource.loginCalls, 1);
      expect(fakeDataSource.lastEmail, 'user@example.com');
      expect(fakeDataSource.lastPassword, 'password123');
    });

    test('propagates exceptions from DataSource', () async {
      fakeDataSource.loginError = ApiException('Invalid email or password');

      expect(
        () => repository.login('user@example.com', 'wrong'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Invalid email or password',
          ),
        ),
      );
    });
  });

  group('signInWithGoogle', () {
    test('delegates to AuthRemoteDataSource.signInWithGoogle', () async {
      await repository.signInWithGoogle();

      expect(fakeDataSource.googleCalls, 1);
    });

    test('propagates exceptions from DataSource', () async {
      fakeDataSource.googleError = ApiException('Google sign-in was cancelled');

      expect(
        () => repository.signInWithGoogle(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Google sign-in was cancelled',
          ),
        ),
      );
    });
  });
}
