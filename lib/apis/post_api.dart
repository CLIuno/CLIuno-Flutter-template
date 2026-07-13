import 'package:dio/dio.dart';

import 'http.dart';

class PostApi {
  Future<Response<dynamic>> getPosts() => http.get('/posts');

  Future<Response<dynamic>> getCurrentUserPosts() =>
      http.get('/posts/current-user');

  Future<Response<dynamic>> getPostById(String id) => http.get('/posts/${id}');

  Future<Response<dynamic>> createPost(Map<String, dynamic> post) =>
      http.post('/posts', data: post);

  Future<Response<dynamic>> updatePost(String id, Map<String, dynamic> post) =>
      http.patch('/posts/${id}', data: post);

  Future<Response<dynamic>> deletePost(String id) =>
      http.delete('/posts/${id}');

  Future<Response<dynamic>> getPostUser(String postId) =>
      http.get('/posts/${postId}/user');

  Future<Response<dynamic>> getComments(String postId) =>
      http.get('/posts/${postId}/comments');

  Future<Response<dynamic>> createComment(
    String postId,
    Map<String, dynamic> comment,
  ) => http.post('/posts/${postId}/comments', data: comment);

  Future<Response<dynamic>> updateComment(
    String postId,
    String commentId,
    Map<String, dynamic> comment,
  ) => http.patch('/posts/${postId}/comments/${commentId}', data: comment);

  Future<Response<dynamic>> deleteComment(String postId, String commentId) =>
      http.delete('/posts/${postId}/comments/${commentId}');
}

final postApi = PostApi();
