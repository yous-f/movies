import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies/core/network/api_client.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/features/browse/presentation/bloc/browse_bloc.dart';
import 'package:movies/features/browse/presentation/bloc/browse_event.dart';
import 'package:movies/features/browse/presentation/bloc/browse_state.dart';
import 'package:movies/features/browse/presentation/widgets/browse_genre_tabs.dart';
import 'package:movies/features/browse/presentation/widgets/browse_movie_grid.dart';
import 'package:movies/features/data/data_sources/move_remote_data_source.dart';
import 'package:movies/features/data/models/movie_model.dart';
import 'package:movies/features/data/repositories/movie_repository.dart';

class BrowseTab extends StatelessWidget {
  const BrowseTab({super.key, this.movieRepository});

  final MovieRepository? movieRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BrowseBloc(
        movieRepository ??
            MovieRepositoryImpl(
              remoteDataSource: MovieRemoteDataSourceImpl(
                apiClient: ApiClient(),
              ),
            ),
      )..add(const BrowseMoviesRequested()),
      child: const _BrowseView(),
    );
  }
}

class _BrowseView extends StatelessWidget {
  const _BrowseView();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: BlocBuilder<BrowseBloc, BrowseState>(
        builder: (context, state) {
          return switch (state) {
            BrowseInitial() || BrowseLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            BrowseFailure(:final message) => _BrowseMessage(
              message: message,
              actionLabel: 'Retry',
              onAction: () => context.read<BrowseBloc>().add(
                const BrowseMoviesRequested(),
              ),
            ),
            BrowseSuccess(
              :final genres,
              :final selectedGenre,
              :final filteredMovies,
              :final allMovies,
            ) =>
              _BrowseContent(
                genres: genres,
                selectedGenre: selectedGenre,
                filteredMovies: filteredMovies,
                allMovies: allMovies,
              ),
          };
        },
      ),
    );
  }
}

class _BrowseContent extends StatelessWidget {
  const _BrowseContent({
    required this.genres,
    required this.selectedGenre,
    required this.filteredMovies,
    required this.allMovies,
  });

  final List<String> genres;
  final String? selectedGenre;
  final List<MovieModel> filteredMovies;
  final List<MovieModel> allMovies;

  @override
  Widget build(BuildContext context) {
    if (allMovies.isEmpty) {
      return const _BrowseMessage(message: 'No movies available.');
    }

    if (genres.isEmpty) {
      return const _BrowseMessage(message: 'No categories available.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        BrowseGenreTabs(
          genres: genres,
          selectedGenre: selectedGenre,
          onGenreSelected: (genre) {
            context.read<BrowseBloc>().add(BrowseGenreSelected(genre));
          },
        ),
        Expanded(
          child: filteredMovies.isEmpty
              ? const _BrowseMessage(
                  message: 'No movies found for this genre.',
                )
              : BrowseMovieGrid(movies: filteredMovies),
        ),
      ],
    );
  }
}

class _BrowseMessage extends StatelessWidget {
  const _BrowseMessage({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
