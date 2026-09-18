import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/errors/network_exception.dart';
import 'package:movies/core/network/api_client.dart';
import 'package:movies/features/browse/presentation/bloc/browse_bloc.dart';
import 'package:movies/features/browse/presentation/bloc/browse_event.dart';
import 'package:movies/features/browse/presentation/bloc/browse_state.dart';
import 'package:movies/features/data/data_sources/move_remote_data_source.dart';
import 'package:movies/features/data/models/movie_model.dart';
import 'package:movies/features/data/repositories/movie_repository.dart';

MovieModel _movie({
  required int id,
  required String title,
  required List<String> genres,
}) {
  return MovieModel(
    id: id,
    title: title,
    year: 2020,
    rating: 7.7,
    runtime: 120,
    genres: genres,
    summary: '',
    mediumCoverImage: 'https://example.com/$id.jpg',
    largeCoverImage: '',
  );
}

class _FakeMovieRepository extends MovieRepository {
  _FakeMovieRepository({
    List<MovieModel> movies = const [],
    Object? error,
  }) : _movies = movies,
       _error = error,
       super(
         remoteDataSource: MovieRemoteDataSource(apiClient: ApiClient()),
       );

  final List<MovieModel> _movies;
  final Object? _error;
  int getMoviesCalls = 0;

  @override
  Future<List<MovieModel>> getMovies({int page = 1, int limit = 20}) async {
    getMoviesCalls++;
    final error = _error;
    if (error != null) {
      throw error;
    }
    return _movies;
  }
}

void main() {
  final actionDrama = _movie(
    id: 1,
    title: 'Movie 1',
    genres: ['Action', 'Drama'],
  );
  final comedy = _movie(id: 2, title: 'Movie 2', genres: ['Comedy']);
  final actionComedy = _movie(
    id: 3,
    title: 'Movie 3',
    genres: ['Action', 'Comedy'],
  );
  final noGenres = _movie(id: 4, title: 'Movie 4', genres: []);
  final blankGenre = _movie(id: 5, title: 'Movie 5', genres: ['  ']);

  test('starts in the initial state', () {
    final bloc = BrowseBloc(_FakeMovieRepository());
    expect(bloc.state, const BrowseInitial());
    bloc.close();
  });

  blocTest<BrowseBloc, BrowseState>(
    'emits loading then success with unique sorted genres and first selected',
    build: () => BrowseBloc(
      _FakeMovieRepository(
        movies: [actionDrama, comedy, actionComedy, noGenres, blankGenre],
      ),
    ),
    act: (bloc) => bloc.add(const BrowseMoviesRequested()),
    expect: () => [
      const BrowseLoading(),
      BrowseSuccess(
        allMovies: [actionDrama, comedy, actionComedy, noGenres, blankGenre],
        genres: ['Action', 'Comedy', 'Drama'],
        selectedGenre: 'Action',
        filteredMovies: [actionDrama, actionComedy],
      ),
    ],
  );

  blocTest<BrowseBloc, BrowseState>(
    'handles an empty movie list without selecting a genre',
    build: () => BrowseBloc(_FakeMovieRepository()),
    act: (bloc) => bloc.add(const BrowseMoviesRequested()),
    expect: () => [
      const BrowseLoading(),
      const BrowseSuccess(
        allMovies: [],
        genres: [],
        selectedGenre: null,
        filteredMovies: [],
      ),
    ],
  );

  blocTest<BrowseBloc, BrowseState>(
    'emits failure when the repository throws',
    build: () => BrowseBloc(
      _FakeMovieRepository(error: NetworkException('No internet connection')),
    ),
    act: (bloc) => bloc.add(const BrowseMoviesRequested()),
    expect: () => [
      const BrowseLoading(),
      const BrowseFailure('No internet connection'),
    ],
  );

  test('filters locally when a genre is selected without another API call',
      () async {
    final repository = _FakeMovieRepository(
      movies: [actionDrama, comedy, actionComedy],
    );
    final bloc = BrowseBloc(repository);

    bloc.add(const BrowseMoviesRequested());
    await bloc.stream.firstWhere((state) => state is BrowseSuccess);

    expect(repository.getMoviesCalls, 1);

    bloc.add(const BrowseGenreSelected('Comedy'));
    await bloc.stream.firstWhere(
      (state) => state is BrowseSuccess && state.selectedGenre == 'Comedy',
    );

    final comedyState = bloc.state as BrowseSuccess;
    expect(comedyState.filteredMovies, [comedy, actionComedy]);
    expect(repository.getMoviesCalls, 1);

    bloc.add(const BrowseGenreSelected('Drama'));
    await bloc.stream.firstWhere(
      (state) => state is BrowseSuccess && state.selectedGenre == 'Drama',
    );

    final dramaState = bloc.state as BrowseSuccess;
    expect(dramaState.filteredMovies, [actionDrama]);
    expect(repository.getMoviesCalls, 1);
    await bloc.close();
  });

  test('ignores genre selection before movies have loaded', () async {
    final bloc = BrowseBloc(_FakeMovieRepository(movies: [comedy]));
    bloc.add(const BrowseGenreSelected('Comedy'));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(bloc.state, const BrowseInitial());
    await bloc.close();
  });
}
