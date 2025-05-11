import 'package:flutter/material.dart';
import 'package:Sehati/models/user_model.dart';
import 'package:Sehati/services/api/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _error;
  User? get currentUser => _user;
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  AuthProvider() {
    _checkAuthentication();
  }

  // Add this new method to clear errors
  void clearErrors() {
    _error = null;
    notifyListeners();
  }

  Future<void> _checkAuthentication() async {
    final token = await _authService.getToken();
    if (token != null) {
      _user = await _authService.getUser();
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password, String passwordConfirmation) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.register(name, email, password, passwordConfirmation);
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }


  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.login(email, password);
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> logout() async {
    _isLoading = true;
    notifyListeners();

    final success = await _authService.logout();
    if (success) {
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> refreshUser() async {
    _user = await _authService.getUser();
    notifyListeners();
  }
}