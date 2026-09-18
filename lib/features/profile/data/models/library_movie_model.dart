import 'package:cloud_firestore/cloud_firestore.dart';

class LibraryMovieModel {
  final int movieId;
  final String title;
  final double rating;
  final String posterUrl;
  final int? year;
  final DateTime? savedAt;

  LibraryMovieModel({
    required this.movieId,
    required this.title,
    required this.rating,
    required this.posterUrl,
    this.year,
    this.savedAt,
  });

  factory LibraryMovieModel.fromFirestore(Map<String, dynamic> json) {
    final timestamp = json['savedAt'];
    return LibraryMovieModel(
      movieId: (json['movieId'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      posterUrl: json['posterUrl'] as String? ?? '',
      year: (json['year'] as num?)?.toInt(),
      savedAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'movieId': movieId,
      'title': title,
      'rating': rating,
      'posterUrl': posterUrl,
      'year': year,
      'savedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toGridItem() {
   return {
    'id': movieId,
    'title': title,
    'rating': rating,
    'imageUrl': posterUrl, 
    'year': year,
  };
  }
}
