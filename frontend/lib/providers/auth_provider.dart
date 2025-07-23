import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  String? token;
  String? role;
  String? username;

  Future<bool> login(String username, String password) async {
    final data = await _authService.login(username, password);
    if (data['token'] != null) {
      token = data['token'];
      role = data['user']['role'];
      this.username = data['user']['username'];
      await _authService.saveToken(token!);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String username, String password, String role) async {
    final data = await _authService.register(username, password, role);
    return data['msg'] == 'User registered successfully';
  }

  Future<void> logout() async {
    await _authService.removeToken();
    token = null;
    role = null;
    username = null;
    notifyListeners();
  }
}
