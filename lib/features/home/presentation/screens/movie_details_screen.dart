import 'package:flutter/material.dart';
import 'package:movies/features/data/data_sources/move_remote_data_source.dart';
import 'package:movies/features/data/repositories/movie_repository.dart';
import 'package:movies/features/home/presentation/movie_details_view_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/state/ui_state.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int movieId;
  static const String routeName = "/details-screen";

  const MovieDetailsScreen({super.key,  required this.movieId});
  // MovieDetailsScreen(this.movieId);

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  late MovieDetailsViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = MovieDetailsViewModel(
      movieRepository: MovieRepositoryImpl(
        remoteDataSource: MovieRemoteDataSourceImpl(apiClient: ApiClient()),
      ),
    );
    viewModel.fetchMovieDetailsAndSuggestions(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121312),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Movie Details'),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, child) {
          final state = viewModel.movieDetailsState;

          switch (state.status) {
            case UiStateStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case UiStateStatus.error:
              return Center(
                child: Text(
                  state.errorMessage ?? "An error occurred",
                  style: const TextStyle(color: Colors.white),
                ),
              );
            case UiStateStatus.success:
              final movie = state.data!;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Poster with Play Button & Overlays
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          movie.largeCoverImage,
                          height: 450,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(height: 450, color: Colors.grey[900]),
                        ),
                        Container(
                          height: 450,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                const Color(0xFF121312).withOpacity(0.8),
                                const Color(0xFF121312),
                              ],
                            ),
                          ),
                        ),
                        // Play Button
                        IconButton(
                          iconSize: 70,
                          icon: const Icon(
                            Icons.play_circle_fill,
                            color: Color(0xFFF6BD00),
                          ),
                          onPressed: () {},
                        ),
                        // Top Action Icons
                        Positioned(
                          top: 10,
                          right: 16,
                          child: IconButton(
                            icon: const Icon(
                              Icons.bookmark_border,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {},
                          ),
                        ),
                        // Title & Year
                        Positioned(
                          bottom: 10,
                          left: 16,
                          right: 16,
                          child: Column(
                            children: [
                              Text(
                                movie.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${movie.year}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Watch Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE50914),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            'Watch',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stats Row (Likes, Duration, Rating)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatBadge(
                            icon: Icons.favorite,
                            iconColor: const Color(0xFFF6BD00),
                            value: '${movie.likeCount?? 0}',
                          ),
                          _buildStatBadge(
                            icon: Icons.access_time_filled,
                            iconColor: const Color(0xFFF6BD00),
                            value: '${movie.runtime ?? 90}',
                          ),
                          _buildStatBadge(
                            icon: Icons.star,
                            iconColor: const Color(0xFFF6BD00),
                            value: '${movie.rating}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Screen Shots Title
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Screen Shots',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Screen Shots List
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              movie.largeCoverImage,
                              width: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 200,
                                color: Colors.grey[800],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            case UiStateStatus.initial:
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required Color iconColor,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF282A28),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
