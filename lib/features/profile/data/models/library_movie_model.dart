import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/models/movie_model.dart';

/// A lightweight snapshot of a movie that we keep in Firestore for a user's
/// Watchlist or History. We intentionally don't store the full [MovieModel]
/// (summary, genres, runtime, ...) since the profile tab only ever needs the
/// poster, title and rating to render [MoviePosterCard].
class LibraryMovieModel {
  final int movieId;
  final String title;
  final double rating;
  final String posterUrl;
  final DateTime? savedAt;

  LibraryMovieModel({
    required this.movieId,
    required this.title,
    required this.rating,
    required this.posterUrl,
    this.savedAt,
  });

  /// Builds the entry that should be written to Firestore from a movie the
  /// user just favorited / opened. This is what the Movie Details screen
  /// (Phase 2 - Task 5) should call when the user taps the favorite icon or
  /// opens a movie.
  factory LibraryMovieModel.fromMovie(MovieModel movie) {
    return LibraryMovieModel(
      movieId: movie.id,
      title: movie.title,
      rating: movie.rating,
      posterUrl: movie.mediumCoverImage.isNotEmpty
          ? movie.mediumCoverImage
          : movie.largeCoverImage,
    );
  }

  factory LibraryMovieModel.fromFirestore(Map<String, dynamic> json) {
    final timestamp = json['savedAt'];
    return LibraryMovieModel(
      movieId: json['movieId'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      posterUrl: json['posterUrl'] as String? ?? '',
      savedAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'movieId': movieId,
      'title': title,
      'rating': rating,
      'posterUrl': posterUrl,
      'savedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Shape expected by the existing [MovieGrid] / [MoviePosterCard] widgets.
  Map<String, dynamic> toGridItem() {
    return {
      'title': title,
      'rating': rating,
      'imageUrl': posterUrl.isNotEmpty ? posterUrl : null,
    };
  }
}
