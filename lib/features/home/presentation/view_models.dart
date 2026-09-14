import 'package:flutter/material.dart';

import '../../../core/state/ui_state.dart';
import '../../data/models/movie_model.dart';
import '../../data/repositories/movie_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final MovieRepository movieRepository;

  UiState<List<MovieModel>> _moviesState = UiState.initial();

  UiState<List<MovieModel>> get moviesState => _moviesState;

  HomeViewModel({required this.movieRepository});

  Future<void> fetchMovies() async {
    _moviesState = UiState.loading();
    notifyListeners();

    try {
      final movies = await movieRepository.getMovies();

      if (movies.isEmpty) {
        _moviesState = UiState.empty();
      } else {
        _moviesState = UiState.success(movies);
      }
    } catch (e) {
      _moviesState = UiState.error(e.toString());
    } finally {
      notifyListeners();
    }
  }
}
