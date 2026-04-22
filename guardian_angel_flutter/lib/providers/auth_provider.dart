import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart'; // Import SocketService

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.post(
        '/auth/login',
        {'email': email, 'password': password},
        includeAuth: false,
      );
      final data = ApiService.handleResponse(response) as Map<String, dynamic>;
      await ApiService.setToken(data['token']);
      await _loadCurrentUser();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String fullName, String phoneNumber, String email, String password) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.post('/auth/register', {
        'fullName': fullName, // Use fullName
        'phoneNumber': phoneNumber, // Use phoneNumber
        'email': email,
        'password': password
      }, includeAuth: false);
      ApiService.handleResponse(response);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    // Prevent multiple logout attempts
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    await ApiService.clearToken();
    _user = null;
    SocketService().disconnect(); // Disconnect socket on logout
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadUser() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      await _loadCurrentUser();
    } catch (e) {
      print('Failed to load user: $e');
      await ApiService.clearToken();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser({
    required String fullName,
    required String email,
    required String phoneNumber,
  }) async {
    if (_user == null) {
      throw Exception('No authenticated user.');
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.put('/auth/profile', {
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
      });
      final responseData = ApiService.handleResponse(response);

      if (responseData is Map<String, dynamic> && responseData.isNotEmpty) {
        _user = UserModel.fromJson(responseData);
      } else {
        _user = UserModel(
          id: _user!.id,
          fullName: fullName,
          email: email,
          phoneNumber: phoneNumber,
          profilePic: _user!.profilePic,
          isAdmin: _user!.isAdmin,
          settings: _user!.settings,
          lastLocation: _user!.lastLocation,
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCurrentUser() async {
    final token = await ApiService.getToken();
    if (token == null) {
      _user = null;
      return;
    }

    final response = await ApiService.get('/auth/me');
    final responseData = ApiService.handleResponse(response) as Map<String, dynamic>;
    _user = UserModel.fromJson(responseData);
    SocketService().connect();
  }
}
