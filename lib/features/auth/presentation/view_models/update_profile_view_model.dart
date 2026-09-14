import 'package:flutter/material.dart';
import 'package:movies/core/state/ui_state.dart';
import 'package:movies/features/auth/data/repositories/auth_repository.dart';

class UpdateProfileViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  UpdateProfileViewModel(this._authRepository);

  UiState<void> _updateState = const UiState.initial();
  UiState<void> get updateState => _updateState;

  Future<void> updateProfile({required String name}) async {
    _updateState = const UiState.loading();
    notifyListeners();

    try {
      await _authRepository.updateProfile(name: name);
      _updateState = const UiState.success(null);
    } catch (e) {
      _updateState = UiState.error(e.toString());
    } finally {
      notifyListeners();
    }
  }
}