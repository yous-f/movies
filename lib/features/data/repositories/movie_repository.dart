import 'package:movies/features/data/data_sources/move_remote_data_source.dart';

import '../models/movie_model.dart';

abstract class MovieRepository {
  Future<List<MovieModel>> getMovies({int page = 1, int limit = 20});
  Future<MovieModel> getMovieDetails(int movieId);
  Future<List<MovieModel>> getMovieSuggestions(int movieId);
}

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;

  MovieRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<MovieModel>> getMovies({int page = 1, int limit = 20}) {
    return remoteDataSource.getMovies(page: page, limit: limit);
  }

  @override
  Future<MovieModel> getMovieDetails(int movieId) {
    return remoteDataSource.getMovieDetails(movieId);
  }

  @override
  Future<List<MovieModel>> getMovieSuggestions(int movieId) {
    return remoteDataSource.getMovieSuggestions(movieId);
  }
}