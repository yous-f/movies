import 'package:flutter/foundation.dart';

import 'package:movies/core/errors/api_exception.dart';
import 'package:movies/core/errors/network_exception.dart';
import 'package:movies/core/state/ui_state.dart';
import 'package:movies/features/auth/data/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._authRepository);

  static final RegExp _emailFormat = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final AuthRepository _authRepository;

  UiState<bool> state = const UiState.initial();

  Future<void> login(String email, String password) async {
    final trimmedEmail = email.trim();
    final validationError = _validate(trimmedEmail, password);
    if (validationError != null) {
      state = UiState.error(validationError);
      notifyListeners();
      return;
    }

    await _runAuth(() => _authRepository.login(trimmedEmail, password));
  }

  Future<void> signInWithGoogle() {
    return _runAuth(_authRepository.signInWithGoogle);
  }

  Future<void> _runAuth(Future<void> Function() action) async {
    state = const UiState.loading();
    notifyListeners();

    try {
      await action();
      state = const UiState.success(true);
    } catch (error) {
      state = UiState.error(_messageFrom(error));
    }

    notifyListeners();
  }

  String? _validate(String email, String password) {
    if (email.isEmpty) {
      return 'Email is required';
    }
    if (!_emailFormat.hasMatch(email)) {
      return 'Enter a valid email';
    }
    if (password.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  String _messageFrom(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    if (error is NetworkException) {
      return error.message;
    }
    return 'Authentication failed';
  }
}
