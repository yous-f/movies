import '../data_sources/profile_remote_data_source.dart';
import '../models/library_movie_model.dart';

class ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepository({required this.remoteDataSource});

  Future<List<LibraryMovieModel>> getWatchlist() {
    return remoteDataSource.getWatchlist();
  }

  Future<void> addToWatchlist(LibraryMovieModel movie) {
    return remoteDataSource.addToWatchlist(movie);
  }

  Future<void> removeFromWatchlist(int movieId) {
    return remoteDataSource.removeFromWatchlist(movieId);
  }

  Future<bool> isInWatchlist(int movieId) {
    return remoteDataSource.isInWatchlist(movieId);
  }

  Future<List<LibraryMovieModel>> getHistory() {
    return remoteDataSource.getHistory();
  }

  Future<void> addToHistory(LibraryMovieModel movie) {
    return remoteDataSource.addToHistory(movie);
  }
}
