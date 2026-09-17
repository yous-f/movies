import 'package:equatable/equatable.dart';
import 'package:movies/features/data/models/movie_model.dart';

sealed class BrowseState extends Equatable {
  const BrowseState();

  @override
  List<Object?> get props => [];
}

final class BrowseInitial extends BrowseState {
  const BrowseInitial();
}

final class BrowseLoading extends BrowseState {
  const BrowseLoading();
}

final class BrowseSuccess extends BrowseState {
  const BrowseSuccess({
    required this.allMovies,
    required this.genres,
    required this.filteredMovies,
    this.selectedGenre,
  });

  final List<MovieModel> allMovies;
  final List<String> genres;
  final String? selectedGenre;
  final List<MovieModel> filteredMovies;

  @override
  List<Object?> get props => [allMovies, genres, selectedGenre, filteredMovies];
}

final class BrowseFailure extends BrowseState {
  const BrowseFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
