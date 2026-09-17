import 'package:flutter/material.dart';
import 'package:movies/features/data/models/movie_model.dart';

class MovieDetailsScreen extends StatelessWidget {
  static const String routeName = '/movie-details';

  const MovieDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final movie = arguments is MovieModel ? arguments : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(movie?.title ?? 'Movie Details'),
      ),
      body: const Center(
        child: Text('Movie details coming soon'),
      ),
    );
  }
}
