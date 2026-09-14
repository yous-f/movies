import 'package:flutter_test/flutter_test.dart';

import 'package:movies/core/errors/api_exception.dart';
import 'package:movies/core/state/ui_state.dart';
import 'package:movies/features/auth/data/repositories/auth_repository.dart';
import 'package:movies/features/auth/presentation/view_models/login_view_model.dart';

class _FakeAuthRepository implements AuthRepository {
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
  late _FakeAuthRepository repository;
  late LoginViewModel viewModel;

  setUp(() {
    repository = _FakeAuthRepository();
    viewModel = LoginViewModel(repository);
  });

  test('starts in the initial state', () {
    expect(viewModel.state.status, UiStateStatus.initial);
  });

  test('empty email shows an error and does not call the repository', () async {
    await viewModel.login('', 'password123');

    expect(viewModel.state.status, UiStateStatus.error);
    expect(viewModel.state.errorMessage, 'Email is required');
    expect(repository.loginCalls, 0);
  });

  test('empty password shows an error and does not call the repository',
      () async {
    await viewModel.login('user@example.com', '');

    expect(viewModel.state.status, UiStateStatus.error);
    expect(viewModel.state.errorMessage, 'Password is required');
    expect(repository.loginCalls, 0);
  });

  test('invalid email shows an error and does not call the repository',
      () async {
    await viewModel.login('not-an-email', 'password123');

    expect(viewModel.state.status, UiStateStatus.error);
    expect(viewModel.state.errorMessage, 'Enter a valid email');
    expect(repository.loginCalls, 0);
  });

  test('valid login goes loading then success', () async {
    final statuses = <UiStateStatus>[];
    viewModel.addListener(() => statuses.add(viewModel.state.status));

    await viewModel.login('  user@example.com  ', 'password123');

    expect(statuses, [UiStateStatus.loading, UiStateStatus.success]);
    expect(viewModel.state.status, UiStateStatus.success);
    expect(viewModel.state.data, isTrue);
    expect(repository.loginCalls, 1);
    expect(repository.lastEmail, 'user@example.com');
    expect(repository.lastPassword, 'password123');
  });

  test('repository failure sets an error state', () async {
    repository.loginError = ApiException('Invalid email or password');

    await viewModel.login('user@example.com', 'wrong-password');

    expect(viewModel.state.status, UiStateStatus.error);
    expect(viewModel.state.errorMessage, 'Invalid email or password');
  });

  test('google login success goes loading then success', () async {
    final statuses = <UiStateStatus>[];
    viewModel.addListener(() => statuses.add(viewModel.state.status));

    await viewModel.signInWithGoogle();

    expect(statuses, [UiStateStatus.loading, UiStateStatus.success]);
    expect(viewModel.state.status, UiStateStatus.success);
    expect(repository.googleCalls, 1);
  });

  test('cancelled google login sets an application-level error', () async {
    repository.googleError = ApiException('Google sign-in was cancelled');

    await viewModel.signInWithGoogle();

    expect(viewModel.state.status, UiStateStatus.error);
    expect(viewModel.state.errorMessage, 'Google sign-in was cancelled');
    expect(repository.googleCalls, 1);
  });

  test('google login failure sets an error state', () async {
    repository.googleError = ApiException('Authentication failed');

    await viewModel.signInWithGoogle();

    expect(viewModel.state.status, UiStateStatus.error);
    expect(viewModel.state.errorMessage, 'Authentication failed');
  });

  test('unknown exception shows generic error message', () async {
    repository.loginError = Exception('Unexpected error');

    await viewModel.login('user@example.com', 'password123');

    expect(viewModel.state.status, UiStateStatus.error);
    expect(viewModel.state.errorMessage, 'Authentication failed');
  });
}
