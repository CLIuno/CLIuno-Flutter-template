import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../apis/auth_api.dart';
import '../apis/http.dart';
import '../apis/user_api.dart';

/// App-wide auth state (the Flutter counterpart of the web templates'
/// zustand/pinia auth store). Token lives in SharedPreferences so the
/// Dio interceptor can read it.
class AuthStore extends ChangeNotifier {
  AuthStore._();

  static final AuthStore instance = AuthStore._();

  Map<String, dynamic>? user;
  bool isAuthenticated = false;
  bool loading = false;
  String? error;

  /// Restore the session on app start: if a token is stored, try to load
  /// the current user; a stale token just clears the session.
  Future<void> hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) return;
    isAuthenticated = true;
    try {
      await fetchCurrentUser();
    } catch (_) {
      await _clear(prefs);
    }
    notifyListeners();
  }

  Future<bool> login(String usernameOrEmail, String password) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final res = await authApi.login({
        'usernameOrEmail': usernameOrEmail,
        'password': password,
      });
      final data = (res.data['data'] as Map).cast<String, dynamic>();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token'] as String);
      if (data['refreshToken'] is String) {
        await prefs.setString('refreshToken', data['refreshToken'] as String);
      }
      isAuthenticated = true;
      await fetchCurrentUser();
      return true;
    } catch (e) {
      error = apiMessage(e);
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await authApi.register(userData);
      return true;
    } catch (e) {
      error = apiMessage(e);
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCurrentUser() async {
    final res = await userApi.getCurrentUser();
    user = ((res.data['data'] as Map)['user'] as Map?)?.cast<String, dynamic>();
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await authApi.logout();
    } catch (_) {
      // Even if the API call fails the local session is dropped.
    }
    final prefs = await SharedPreferences.getInstance();
    await _clear(prefs);
    notifyListeners();
  }

  Future<void> _clear(SharedPreferences prefs) async {
    await prefs.remove('token');
    await prefs.remove('refreshToken');
    user = null;
    isAuthenticated = false;
  }
}
