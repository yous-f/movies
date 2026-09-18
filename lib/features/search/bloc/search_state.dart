import 'package:equatable/equatable.dart';
import 'package:movies/features/data/models/movie_model.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

final class SearchInitial extends SearchState {
  const SearchInitial();
}

final class SearchLoading extends SearchState {
  const SearchLoading();
}

final class SearchSuccess extends SearchState {
  const SearchSuccess(this.movies);

  final List<MovieModel> movies;

  @override
  List<Object?> get props => [movies];
}

final class SearchEmpty extends SearchState {
  const SearchEmpty();
}

final class SearchFailure extends SearchState {
  const SearchFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}