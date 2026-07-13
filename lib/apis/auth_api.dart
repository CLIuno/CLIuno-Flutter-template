import 'package:dio/dio.dart';

import 'http.dart';

class AuthApi {
  Future<Response<dynamic>> login(Map<String, dynamic> credentials) =>
      http.post('/auth/login', data: credentials);

  Future<Response<dynamic>> register(Map<String, dynamic> userData) =>
      http.post('/auth/register', data: userData);

  Future<Response<dynamic>> logout() => http.post('/auth/logout');

  Future<Response<dynamic>> forgotPassword(String email) =>
      http.post('/auth/forgot-password', data: {'email': email});
}

final authApi = AuthApi();
