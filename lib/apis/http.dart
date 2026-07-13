import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Base URL of any CLIuno backend template.
/// Override at build time: flutter run --dart-define=API_BASE=http://10.0.2.2:3000/api/v1
const apiBase = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'http://localhost:3000/api/v1',
);

/// Shared Dio instance: attaches the Bearer token and drops it on 401,
/// mirroring the axios interceptors used by the web templates.
final Dio http = _build();

Dio _build() {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBase,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('token');
          await prefs.remove('refreshToken');
        }
        handler.next(e);
      },
    ),
  );

  return dio;
}

/// Human-readable message out of a failed request — backends answer
/// `{status, message, data}` even on errors.
String apiMessage(Object e) {
  if (e is DioException) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return e.message ?? 'Network error';
  }
  return e.toString();
}
