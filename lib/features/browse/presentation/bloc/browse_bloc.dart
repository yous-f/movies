import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies/features/browse/presentation/bloc/browse_event.dart';
import 'package:movies/features/browse/presentation/bloc/browse_state.dart';
import 'package:movies/features/data/models/movie_model.dart';
import 'package:movies/features/data/repositories/movie_repository.dart';

class BrowseBloc extends Bloc<BrowseEvent, BrowseState> {
  BrowseBloc(this._movieRepository) : super(const BrowseInitial()) {
    on<BrowseMoviesRequested>(_onMoviesRequested);
    on<BrowseGenreSelected>(_onGenreSelected);
  }

  final MovieRepository _movieRepository;

  Future<void> _onMoviesRequested(
    BrowseMoviesRequested event,
    Emitter<BrowseState> emit,
  ) async {
    emit(const BrowseLoading());

    try {
      final movies = await _movieRepository.getMovies();
      final genres = _uniqueGenres(movies);
      final selectedGenre = genres.isEmpty ? null : genres.first;

      emit(
        BrowseSuccess(
          allMovies: movies,
          genres: genres,
          selectedGenre: selectedGenre,
          filteredMovies: _filterByGenre(movies, selectedGenre),
        ),
      );
    } catch (error) {
      emit(BrowseFailure(error.toString()));
    }
  }

  void _onGenreSelected(
    BrowseGenreSelected event,
    Emitter<BrowseState> emit,
  ) {
    final current = state;
    if (current is! BrowseSuccess) {
      return;
    }

    emit(
      BrowseSuccess(
        allMovies: current.allMovies,
        genres: current.genres,
        selectedGenre: event.genre,
        filteredMovies: _filterByGenre(current.allMovies, event.genre),
      ),
    );
  }

  List<String> _uniqueGenres(List<MovieModel> movies) {
    final genres = <String>{};

    for (final movie in movies) {
      for (final genre in movie.genres) {
        final trimmed = genre.trim();
        if (trimmed.isNotEmpty) {
          genres.add(trimmed);
        }
      }
    }

    final genreList = genres.toList()..sort();
    return genreList;
  }

  List<MovieModel> _filterByGenre(
    List<MovieModel> movies,
    String? selectedGenre,
  ) {
    if (selectedGenre == null) {
      return const [];
    }

    return movies
        .where((movie) => movie.genres.contains(selectedGenre))
        .toList();
  }
}
