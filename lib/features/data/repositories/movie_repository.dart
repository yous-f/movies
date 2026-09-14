
import '../data_sources/move_remote_data_source.dart';
import '../models/movie_model.dart';

class MovieRepository {
  final MovieRemoteDataSource remoteDataSource;

  MovieRepository({required this.remoteDataSource});

  Future<List<MovieModel>> getMovies({int page = 1, int limit = 20}) async {
    return await remoteDataSource.getMovies(page: page, limit: limit);
  }

}