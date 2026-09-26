import 'package:dio/dio.dart';

import '../openf1_exception.dart';
import 'openf1_auth.dart';

class OpenF1Api {
  OpenF1Api({Dio? dio, OpenF1Auth? auth})
      : auth = auth ?? OpenF1Auth(),
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://api.openf1.org/v1',
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 25),
                responseType: ResponseType.json,
              ),
            ) {
    _dio.interceptors.add(_AuthInterceptor(this.auth, _dio));
  }

  final Dio _dio;
  final OpenF1Auth auth;

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
      final wrapped = error.error;
      if (wrapped is OpenF1Exception) throw wrapped;
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

class _AuthInterceptor extends QueuedInterceptor {
  _AuthInterceptor(this._auth, this._dio);

  final OpenF1Auth _auth;
  final Dio _dio;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await _auth.token();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      options.headers['accept'] = 'application/json';
      handler.next(options);
    } catch (error, stack) {
      handler.reject(
        DioException(requestOptions: options, error: error, stackTrace: stack),
      );
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final already = err.requestOptions.extra['openf1_retried'] == true;
    if (err.response?.statusCode == 401 && !already && _auth.configured) {
      try {
        final token = await _auth.token(force: true);
        if (token != null) {
          final request = err.requestOptions;
          request.headers['Authorization'] = 'Bearer $token';
          request.extra['openf1_retried'] = true;
          handler.resolve(await _dio.fetch<dynamic>(request));
          return;
        }
      } catch (_) {
        // Fall through to the original 401.
      }
    }
    handler.next(err);
  }
}
