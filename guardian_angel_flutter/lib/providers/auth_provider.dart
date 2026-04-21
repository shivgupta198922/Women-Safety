import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post('/auth/login', {'email': email, 'password': password});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await ApiService.setToken(data['token']);
        _user = UserModel.fromJson(data['user']);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String phone, String password) async {
    // similar to login, post /auth/register
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post('/auth/register', {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password
      });
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        await ApiService.setToken(data['token']);
        _user = UserModel.fromJson(data['user']);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await ApiService.clearToken();
    _user = null;
    notifyListeners();
  }

  Future<void> loadUser() async {
    final token = await ApiService.getToken();
    if (token != null) {
final response = await ApiService.get('/users/profile');
      if (response.statusCode == 200) {
        _user = UserModel.fromJson(json.decode(response.body));
        notifyListeners();
      }
    }
  }
}
