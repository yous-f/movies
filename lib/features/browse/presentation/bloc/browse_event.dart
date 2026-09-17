import 'package:equatable/equatable.dart';

sealed class BrowseEvent extends Equatable {
  const BrowseEvent();

  @override
  List<Object?> get props => [];
}

final class BrowseMoviesRequested extends BrowseEvent {
  const BrowseMoviesRequested();
}

final class BrowseGenreSelected extends BrowseEvent {
  const BrowseGenreSelected(this.genre);

  final String genre;

  @override
  List<Object?> get props => [genre];
}
