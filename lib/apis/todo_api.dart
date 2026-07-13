import 'package:dio/dio.dart';

import 'http.dart';

class TodoApi {
  Future<Response<dynamic>> getTodos() => http.get('/todos');

  Future<Response<dynamic>> getTodoById(String id) => http.get('/todos/${id}');

  Future<Response<dynamic>> createTodo(Map<String, dynamic> todo) =>
      http.post('/todos', data: todo);

  Future<Response<dynamic>> updateTodo(String id, Map<String, dynamic> todo) =>
      http.patch('/todos/${id}', data: todo);

  Future<Response<dynamic>> toggleTodo(String id) =>
      http.patch('/todos/${id}/toggle');

  Future<Response<dynamic>> deleteTodo(String id) =>
      http.delete('/todos/${id}');
}

final todoApi = TodoApi();
