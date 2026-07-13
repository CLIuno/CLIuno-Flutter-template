import 'package:dio/dio.dart';

import 'http.dart';

class FollowApi {
  Future<Response<dynamic>> getFollowers(String userId) =>
      http.get('/follows/${userId}/followers');

  Future<Response<dynamic>> getFollowing(String userId) =>
      http.get('/follows/${userId}/following');

  Future<Response<dynamic>> isFollowing(String userId) =>
      http.get('/follows/${userId}/is-following');

  Future<Response<dynamic>> follow(String userId) =>
      http.post('/follows/${userId}/follow');

  Future<Response<dynamic>> unfollow(String userId) =>
      http.delete('/follows/${userId}/follow');
}

final followApi = FollowApi();
