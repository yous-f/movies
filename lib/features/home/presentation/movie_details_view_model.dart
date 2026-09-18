import 'package:flutter/material.dart';
import 'package:movies/features/profile/data/models/library_movie_model.dart';
import 'package:movies/features/profile/data/repositories/profile_repository.dart';

import '../../../core/state/ui_state.dart';
import '../../data/models/movie_model.dart';
import '../../data/repositories/movie_repository.dart';

class MovieDetailsViewModel extends ChangeNotifier {
  final MovieRepository movieRepository;
  final ProfileRepository profileRepository;

  UiState<MovieModel> _movieDetailsState = UiState.initial();
  UiState<MovieModel> get movieDetailsState => _movieDetailsState;

  UiState<List<MovieModel>> _suggestionsState = UiState.initial();
  UiState<List<MovieModel>> get suggestionsState => _suggestionsState;

  MovieDetailsViewModel({
    required this.movieRepository,
    required this.profileRepository,
  });

  Future<void> fetchMovieDetailsAndSuggestions(int movieId) async {
    fetchMovieDetails(movieId);
    fetchMovieSuggestions(movieId);
  }

  Future<void> fetchMovieDetails(int movieId) async {
    _movieDetailsState = UiState.loading();
    notifyListeners();

    try {
      final movieDetails = await movieRepository.getMovieDetails(movieId);
      _movieDetailsState = UiState.success(movieDetails);
    } catch (e) {
      _movieDetailsState = UiState.error(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchMovieSuggestions(int movieId) async {
    _suggestionsState = UiState.loading();
    notifyListeners();

    try {
      final suggestions = await movieRepository.getMovieSuggestions(movieId);

      if (suggestions.isEmpty) {
        _suggestionsState = UiState.empty();
      } else {
        _suggestionsState = UiState.success(suggestions);
      }
    } catch (e) {
      _suggestionsState = UiState.error(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<void> watchMovie(MovieModel movie) async {
  final libraryMovie = LibraryMovieModel(
    movieId: movie.id, 
    title: movie.title,
    posterUrl: movie.largeCoverImage,
    rating: movie.rating,
    year: movie.year,
    savedAt: DateTime.now(),
  );

  await profileRepository.addToWatchlist(libraryMovie);
  await profileRepository.addToHistory(libraryMovie);
}
}