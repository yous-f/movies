import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/errors/server_exception.dart';
import 'package:movies/core/network/api_client.dart';
import 'package:movies/features/data/models/movie_model.dart';

// Abstract interface
import 'package:movies/features/data/data_sources/move_remote_data_source.dart';

// TODO: Ensure this import points to your concrete implementation file
// import 'package:movies/features/data/data_sources/move_remote_data_source_impl.dart';

class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
      RequestOptions options,
      Stream<Uint8List>? requestStream,
      Future<void>? cancelFuture,
      ) async {
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

// Return the abstract type, but instantiate the Impl
MovieRemoteDataSource _dataSource(int statusCode, Object body) {
  final dio = Dio(BaseOptions(baseUrl: ApiClient.baseUrl));
  dio.httpClientAdapter = _JsonAdapter(statusCode, jsonEncode(body));

  // Use MovieRemoteDataSourceImpl here
  return MovieRemoteDataSourceImpl(apiClient: ApiClient(dio: dio));
}

void main() {
  test('parses a movie list from the YTS response', () async {
    final dataSource = _dataSource(200, {
      'data': {
        'movies': [
          {
            'id': 1,
            'title': 'Black Widow',
            'year': 2021,
            'rating': 7.7,
            'runtime': 134,
            'genres': ['Action', 'Adventure'],
            'summary': '',
            'medium_cover_image': 'https://example.com/a.jpg',
            'large_cover_image': 'https://example.com/b.jpg',
          },
        ],
      },
    });

    final movies = await dataSource.getMovies();

    expect(movies, hasLength(1));
    expect(movies.first.title, 'Black Widow');
    expect(movies.first.genres, ['Action', 'Adventure']);
  });

  test('returns an empty list when movies are missing', () async {
    final dataSource = _dataSource(200, {
      'data': {'movies': null},
    });

    expect(await dataSource.getMovies(), isEmpty);
  });

  test('treats missing genres as an empty list', () {
    final movie = MovieModel.fromJson({
      'id': 10,
      'title': 'No Genres',
    });

    expect(movie.genres, isEmpty);
  });

  test('throws ServerException when the API fails', () async {
    final dataSource = _dataSource(500, {'status': 'error'});

    expect(dataSource.getMovies(), throwsA(isA<ServerException>()));
  });
}