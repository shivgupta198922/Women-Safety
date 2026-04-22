import 'package:flutter/material.dart';
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

  Future<bool> login(String email, String password, {String? accountType}) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.post(
        '/auth/login',
        {
          'identifier': email.trim(),
          'password': password,
          if (accountType != null && accountType.trim().isNotEmpty) 'accountType': accountType.trim(),
        },
        includeAuth: false,
      );
      final data = ApiService.handleResponse(response) as Map<String, dynamic>;
      await ApiService.setToken(data['token']);
      if (data['user'] is Map<String, dynamic>) {
        _user = UserModel.fromJson(Map<String, dynamic>.from(data['user']));
        SocketService().connect(
          userId: _user?.id,
          accountType: _user?.accountType,
          userName: _user?.fullName,
        );
      } else {
        await _loadCurrentUser();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
    String accountType = 'individual',
    String? organizationName,
    String? departmentName,
    Map<String, dynamic>? securePairing,
  }) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.post(
        '/auth/register',
        {
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'email': email,
          'password': password,
          'accountType': accountType,
          if (organizationName != null && organizationName.trim().isNotEmpty) 'organizationName': organizationName.trim(),
          if (departmentName != null && departmentName.trim().isNotEmpty) 'departmentName': departmentName.trim(),
          if (securePairing != null) 'securePairing': securePairing,
        },
        includeAuth: false,
      );
      final data = ApiService.handleResponse(response);
      if (data is Map<String, dynamic> && data['token'] is String) {
        await ApiService.setToken(data['token']);
      }
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
          accountType: _user!.accountType,
          organizationName: _user!.organizationName,
          departmentName: _user!.departmentName,
          profilePic: _user!.profilePic,
          isAdmin: _user!.isAdmin,
          settings: _user!.settings,
          lastLocation: _user!.lastLocation,
          securePairing: _user!.securePairing,
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
    SocketService().connect(
      userId: _user?.id,
      accountType: _user?.accountType,
      userName: _user?.fullName,
    );
  }
}
