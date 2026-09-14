
import '../../../core/network/api_client.dart';
import '../models/movie_model.dart';


class MovieRemoteDataSource {
  final ApiClient apiClient;

  MovieRemoteDataSource({required this.apiClient});

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
}