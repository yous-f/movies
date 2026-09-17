import 'package:flutter/material.dart';
import 'package:movies/features/data/models/movie_model.dart';
import 'package:movies/features/movie_details/presentation/screens/movie_details_screen.dart';
import 'package:movies/shared/widgets/movie_card.dart';

class BrowseMovieGrid extends StatelessWidget {
  const BrowseMovieGrid({super.key, required this.movies});

  final List<MovieModel> movies;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _crossAxisCount(context),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 189 / 279,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        final imageUrl = movie.mediumCoverImage.isNotEmpty
            ? movie.mediumCoverImage
            : movie.largeCoverImage;

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              MovieDetailsScreen.routeName,
              arguments: movie,
            );
          },
          child: MovieCard(imageUrl: imageUrl, rating: movie.rating),
        );
      },
    );
  }

  int _crossAxisCount(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 400) return 2;
    if (width < 600) return 3;
    if (width < 900) return 4;
    return 5;
  }
}
