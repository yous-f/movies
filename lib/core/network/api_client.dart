import 'dart:io';

import 'package:dio/dio.dart';
import 'package:movies/core/errors/network_exception.dart';
import 'package:movies/core/errors/server_exception.dart';

class ApiClient {
  static const String baseUrl = 'https://movies-api.accel.li/api/v2/';

  final Dio _dio;

  ApiClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              responseType: ResponseType.json,
            ),
          );

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        endpoint,
        queryParameters: queryParameters,
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300) {
        return response.data;
      }

      throw ServerException(statusCode);
    } on DioException catch (error) {
      if (_isNetworkFailure(error)) {
        throw NetworkException('No internet connection');
      }

      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        throw ServerException(statusCode);
      }

      throw NetworkException('Network request failed');
    } on SocketException {
      throw NetworkException('No internet connection');
    }
  }

  bool _isNetworkFailure(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.error is SocketException;
  }
}
