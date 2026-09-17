import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:movies/core/state/ui_state.dart';

import '../../data/models/library_movie_model.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository profileRepository;
  final FirebaseAuth _firebaseAuth;

  ProfileViewModel({required this.profileRepository, FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  UiState<List<LibraryMovieModel>> _watchlistState = const UiState.initial();
  UiState<List<LibraryMovieModel>> get watchlistState => _watchlistState;

  UiState<List<LibraryMovieModel>> _historyState = const UiState.initial();
  UiState<List<LibraryMovieModel>> get historyState => _historyState;

  String get userName {
    final name = _firebaseAuth.currentUser?.displayName;
    return (name != null && name.trim().isNotEmpty) ? name : 'Guest';
  }

  int get watchlistCount => _watchlistState.data?.length ?? 0;
  int get historyCount => _historyState.data?.length ?? 0;

  Future<void> loadProfileData() async {
    await Future.wait([fetchWatchlist(), fetchHistory()]);
  }

  Future<void> fetchWatchlist() async {
    _watchlistState = const UiState.loading();
    notifyListeners();

    try {
      final movies = await profileRepository.getWatchlist();
      _watchlistState = movies.isEmpty
          ? const UiState.empty()
          : UiState.success(movies);
    } catch (e) {
      _watchlistState = UiState.error(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchHistory() async {
    _historyState = const UiState.loading();
    notifyListeners();

    try {
      final movies = await profileRepository.getHistory();
      _historyState = movies.isEmpty
          ? const UiState.empty()
          : UiState.success(movies);
    } catch (e) {
      _historyState = UiState.error(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }
}
