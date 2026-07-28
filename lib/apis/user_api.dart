import 'package:dio/dio.dart';

import 'http.dart';

class UserApi {
  Future<Response<dynamic>> getCurrentUser() => http.get('/users/current');

  Future<Response<dynamic>> updateCurrentUser(Map<String, dynamic> userData) =>
      http.patch('/users/current', data: userData);

  Future<Response<dynamic>> getUsers() => http.get('/users');

  Future<Response<dynamic>> getUserById(String id) => http.get('/users/${id}');
}

final userApi = UserApi();
