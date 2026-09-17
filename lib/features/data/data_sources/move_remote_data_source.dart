import '../../../core/network/api_client.dart';
import '../models/movie_model.dart';

abstract class MovieRemoteDataSource {
  Future<List<MovieModel>> getMovies({int page = 1, int limit = 20});
  Future<MovieModel> getMovieDetails(int movieId);
  Future<List<MovieModel>> getMovieSuggestions(int movieId);
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final ApiClient apiClient;

  MovieRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<MovieModel>> getMovies({int page = 1, int limit = 20}) async {
    final response = await apiClient.get(
      'list_movies.json',
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    if (response['data'] != null && response['data']['movies'] != null) {
      final List<dynamic> moviesJson = response['data']['movies'];
      return moviesJson.map((json) => MovieModel.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  @override
  Future<MovieModel> getMovieDetails(int movieId) async {
    final response = await apiClient.get(
      'movie_details.json',
      queryParameters: {
        'movie_id': movieId.toString(),
      },
    );

    if (response['data'] != null && response['data']['movie'] != null) {
      return MovieModel.fromJson(response['data']['movie']);
    } else {
      throw Exception('Movie details not found');
    }
  }

  @override
  Future<List<MovieModel>> getMovieSuggestions(int movieId) async {
    final response = await apiClient.get(
      'movie_suggestions.json',
      queryParameters: {
        'movie_id': movieId.toString(),
      },
    );

    if (response['data'] != null && response['data']['movies'] != null) {
      final List<dynamic> moviesJson = response['data']['movies'];
      return moviesJson.map((json) => MovieModel.fromJson(json)).toList();
    } else {
      return [];
    }
  }
}