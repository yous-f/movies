class MovieModel {
  final int id;
  final String title;
  final int year;
  final double rating;
  final int runtime;
  final List<String> genres;
  final String summary;
  final String mediumCoverImage;
  final String largeCoverImage;

  MovieModel({
    required this.id,
    required this.title,
    required this.year,
    required this.rating,
    required this.runtime,
    required this.genres,
    required this.summary,
    required this.mediumCoverImage,
    required this.largeCoverImage,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int,
      title: json['title'] ?? '',
      year: json['year'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      runtime: json['runtime'] as int? ?? 0,
      genres: (json['genres'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      summary: json['summary'] ?? '',
      mediumCoverImage: json['medium_cover_image'] ?? '',
      largeCoverImage: json['large_cover_image'] ?? '',
    );
  }
}