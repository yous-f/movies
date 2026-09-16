import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:movies/core/errors/api_exception.dart';
import 'package:movies/core/errors/network_exception.dart';

import '../models/library_movie_model.dart';

/// How many history entries we keep per user. History should feel like a
/// "recently visited" list, not an ever-growing log.
const int kHistoryLimit = 30;

class ProfileRemoteDataSource {
  ProfileRemoteDataSource({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw ApiException('No user currently logged in');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _watchlistRef =>
      _firestore.collection('users').doc(_uid).collection('watchlist');

  CollectionReference<Map<String, dynamic>> get _historyRef =>
      _firestore.collection('users').doc(_uid).collection('history');

  Future<List<LibraryMovieModel>> getWatchlist() async {
    try {
      final snapshot = await _watchlistRef
          .orderBy('savedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => LibraryMovieModel.fromFirestore(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ApiException(e.message ?? 'Failed to load watch list');
    } catch (e) {
      throw NetworkException('No internet connection');
    }
  }

  Future<void> addToWatchlist(LibraryMovieModel movie) async {
    try {
      await _watchlistRef
          .doc(movie.movieId.toString())
          .set(movie.toFirestore());
    } on FirebaseException catch (e) {
      throw ApiException(e.message ?? 'Failed to add movie to watch list');
    } catch (e) {
      throw NetworkException('No internet connection');
    }
  }

  Future<void> removeFromWatchlist(int movieId) async {
    try {
      await _watchlistRef.doc(movieId.toString()).delete();
    } on FirebaseException catch (e) {
      throw ApiException(
        e.message ?? 'Failed to remove movie from watch list',
      );
    } catch (e) {
      throw NetworkException('No internet connection');
    }
  }

  Future<bool> isInWatchlist(int movieId) async {
    try {
      final doc = await _watchlistRef.doc(movieId.toString()).get();
      return doc.exists;
    } on FirebaseException catch (e) {
      throw ApiException(e.message ?? 'Failed to check watch list');
    } catch (e) {
      throw NetworkException('No internet connection');
    }
  }

  Future<List<LibraryMovieModel>> getHistory() async {
    try {
      final snapshot = await _historyRef
          .orderBy('savedAt', descending: true)
          .limit(kHistoryLimit)
          .get();

      return snapshot.docs
          .map((doc) => LibraryMovieModel.fromFirestore(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ApiException(e.message ?? 'Failed to load history');
    } catch (e) {
      throw NetworkException('No internet connection');
    }
  }

  /// Records that the user visited a movie. Re-visiting a movie just bumps
  /// its timestamp to the top instead of creating a duplicate entry, since
  /// the document id is the movie id.
  Future<void> addToHistory(LibraryMovieModel movie) async {
    try {
      await _historyRef
          .doc(movie.movieId.toString())
          .set(movie.toFirestore());
    } on FirebaseException catch (e) {
      throw ApiException(e.message ?? 'Failed to update history');
    } catch (e) {
      throw NetworkException('No internet connection');
    }
  }
}
