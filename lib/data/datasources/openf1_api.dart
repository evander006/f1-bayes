import 'package:dio/dio.dart';

import '../openf1_exception.dart';

class OpenF1Api {
  OpenF1Api({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://api.openf1.org/v1',
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 25),
                responseType: ResponseType.json,
              ),
            );

  final Dio _dio;

  Future<List<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: {
          if (query != null)
            for (final entry in query.entries)
              if (entry.value != null) entry.key: entry.value,
        },
      );
      final data = response.data;
      if (data is! List) {
        throw OpenF1Exception.malformed();
      }
      return [
        for (final item in data)
          if (item is Map) Map<String, dynamic>.from(item),
      ];
    } on OpenF1Exception {
      rethrow;
    } on DioException catch (error) {
      throw _mapDio(error);
    }
  }

  OpenF1Exception _mapDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return OpenF1Exception.timeout();
      case DioExceptionType.connectionError:
        return OpenF1Exception.network();
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode ?? 0;
        if (code == 401 || code == 403) {
          return OpenF1Exception.subscription();
        }
        return OpenF1Exception.http(code);
      default:
        return OpenF1Exception.network();
    }
  }
}
