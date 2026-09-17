import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/network/api_client.dart';
import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/features/browse/presentation/screens/browse_tab.dart';
import 'package:movies/features/browse/presentation/widgets/browse_genre_tabs.dart';
import 'package:movies/features/data/data_sources/move_remote_data_source.dart';
import 'package:movies/features/data/models/movie_model.dart';
import 'package:movies/features/data/repositories/movie_repository.dart';
import 'package:movies/features/movie_details/presentation/screens/movie_details_screen.dart';

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

  @override
  Future<List<MovieModel>> getMovies({int page = 1, int limit = 20}) async {
    final error = _error;
    if (error != null) {
      throw error;
    }
    return _movies;
  }
}

MovieModel _movie(String title, List<String> genres) {
  return MovieModel(
    id: title.hashCode,
    title: title,
    year: 2021,
    rating: 7.7,
    runtime: 120,
    genres: genres,
    summary: '',
    mediumCoverImage: 'assets/images/card.png',
    largeCoverImage: 'assets/images/card.png',
  );
}

Widget _app(Widget home) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    routes: {
      MovieDetailsScreen.routeName: (_) => const MovieDetailsScreen(),
    },
    home: home,
  );
}

void main() {
  testWidgets('genre tabs call onGenreSelected', (tester) async {
    String? selected;

    await tester.pumpWidget(
      _app(
        Scaffold(
          body: BrowseGenreTabs(
            genres: const ['Action', 'Comedy'],
            selectedGenre: 'Action',
            onGenreSelected: (genre) => selected = genre,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Comedy'));
    expect(selected, 'Comedy');
  });

  testWidgets('shows a loading indicator then genre tabs and movies',
      (tester) async {
    await tester.pumpWidget(
      _app(
        BrowseTab(
          movieRepository: _FakeMovieRepository(
            movies: [
              _movie('Action One', ['Action']),
              _movie('Comedy One', ['Comedy']),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Action'), findsOneWidget);
    expect(find.text('Comedy'), findsOneWidget);
    expect(find.text('No movies available.'), findsNothing);
  });

  testWidgets('shows an error and retries', (tester) async {
    await tester.pumpWidget(
      _app(
        BrowseTab(
          movieRepository: _FakeMovieRepository(error: Exception('offline')),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('offline'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('shows an empty movies message', (tester) async {
    await tester.pumpWidget(
      _app(
        BrowseTab(movieRepository: _FakeMovieRepository()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No movies available.'), findsOneWidget);
  });
}
