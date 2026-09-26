import 'package:dio/dio.dart';

import 'openf1_secrets.dart';
import '../openf1_exception.dart';

class OpenF1Auth {
  OpenF1Auth({
    String? username,
    String? password,
    Dio? dio,
  })  : username = username ?? OpenF1Secrets.username,
        password = password ?? OpenF1Secrets.password,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://api.openf1.org',
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 20),
                responseType: ResponseType.json,
              ),
            );

  final String username;
  final String password;
  final Dio _dio;

  String? _accessToken;
  DateTime? _expiresAt;

  DateTime? get expiresAt => _expiresAt;
  bool get configured => username.isNotEmpty && password.isNotEmpty;
  bool get hasValidToken =>
      _accessToken != null &&
      _expiresAt != null &&
      DateTime.now().isBefore(_expiresAt!.subtract(const Duration(seconds: 60)));

  Future<String?> token({bool force = false}) async {
    if (!configured) return null;
    if (!force && hasValidToken) return _accessToken;
    await _fetch();
    return _accessToken;
  }

  Future<void> _fetch() async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/token',
        data: {
          'username': username,
          'password': password,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      final data = response.data;
      if (data == null) throw OpenF1Exception.malformed();
      final token = data['access_token']?.toString();
      if (token == null || token.isEmpty) throw OpenF1Exception.malformed();
      final expiresRaw = data['expires_in'];
      final expiresSeconds = expiresRaw is num
          ? expiresRaw.toInt()
          : int.tryParse(expiresRaw?.toString() ?? '') ?? 3600;
      _accessToken = token;
      _expiresAt = DateTime.now().add(Duration(seconds: expiresSeconds));
    } on OpenF1Exception {
      rethrow;
    } on DioException catch (error) {
      final code = error.response?.statusCode ?? 0;
      if (code == 401 || code == 403) {
        throw OpenF1Exception.subscription();
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        throw OpenF1Exception.timeout();
      }
      throw OpenF1Exception.network();
    }
  }
}
