import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  String? _token;
  String? _role;
  String? _username;

  // Getters
  String? get token => _token;
  String? get role => _role;
  String? get username => _username;

  // Pour la compatibilité avec ton LoginScreen (userRole)
  String? get userRole => _role;

  // Connexion utilisateur
  Future<bool> login(String username, String password) async {
    try {
      final data = await _authService.login(username, password);
      if (data['token'] != null && data['user'] != null) {
        _token = data['token'];
        _role = data['user']['role']?.toString()?.toLowerCase(); // normalisé
        _username = data['user']['username'];
        await _authService.saveToken(_token!);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      // Gérer l’erreur de connexion ici si besoin
      return false;
    }
  }

  // Inscription utilisateur
  Future<bool> register(String username, String password, String role) async {
    try {
      final data = await _authService.register(username, password, role);
      return data['msg'] == 'User registered successfully';
    } catch (e) {
      return false;
    }
  }

  // Déconnexion utilisateur
  Future<void> logout() async {
    await _authService.removeToken();
    _token = null;
    _role = null;
    _username = null;
    notifyListeners();
  }
}
