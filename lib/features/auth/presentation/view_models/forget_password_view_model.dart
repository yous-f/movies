import 'package:flutter/foundation.dart';

import '../../../../core/state/ui_state.dart';
import '../../data/repositories/auth_repository_impl.dart';

class ForgetPasswordViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  ForgetPasswordViewModel(this._authRepository);

  UiState<void> _state = const UiState.initial();
  UiState<void> get state => _state;

  static final RegExp _emailRegex = RegExp(
    r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$',
  );

  Future<void> sendResetEmail(String rawEmail) async {
    final email = rawEmail.trim();

    
    if (email.isEmpty) {
      _emitError('Please enter your email address.');
      return;
    }
    if (!_emailRegex.hasMatch(email)) {
      _emitError('Please enter a valid email address.');
      return;
    }

    _state = const UiState.loading();
    notifyListeners();

    try {
      await _authRepository.sendPasswordResetEmail(email);
      _state = const UiState.success(null);
    } catch (e) {
      _state = UiState.error(e.toString().replaceFirst('Exception: ', ''));
    }
    notifyListeners();
  }

  void _emitError(String message) {
    _state = UiState.error(message);
    notifyListeners();
  }
  void resetState() {
    _state = const UiState.initial();
    notifyListeners();
  }
}
