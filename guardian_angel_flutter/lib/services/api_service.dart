import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guardian_angel_flutter/constants/app_constants.dart'; // Corrected import
 
class ApiService {
  static const String _baseUrl = AppConstants.baseUrl;
  static const String _tokenKey = 'jwt_token';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (includeAuth) {
      final token = await getToken();
      if (token != null) {
        headers['x-auth-token'] = token; // Use 'x-auth-token' as per backend
      }
    }
    return headers;
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> data, {bool includeAuth = true}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(includeAuth: includeAuth);
    return http.post(
      url,
      headers: headers,
      body: json.encode(data),
    );
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> data, {bool includeAuth = true}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(includeAuth: includeAuth);
    return http.put(
      url,
      headers: headers,
      body: json.encode(data),
    );
  }

  static Future<http.Response> get(String endpoint, {bool includeAuth = true}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(includeAuth: includeAuth);
    return http.get(
      url,
      headers: headers,
    );
  }

  static Future<http.Response> delete(String endpoint, {bool includeAuth = true}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(includeAuth: includeAuth);
    return http.delete(
      url,
      headers: headers,
    );
  }


  // Helper to handle API responses and throw specific exceptions
  static dynamic handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      final errorBody = json.decode(response.body);
      if (errorBody['errors'] != null && errorBody['errors'].isNotEmpty) {
        throw Exception(errorBody['errors'][0]['msg']);
      } else {
        throw Exception(
          errorBody['msg'] ??
          errorBody['error'] ??
          errorBody['message'] ??
          'An unknown error occurred: ${response.statusCode}',
        );
      }
    }
  }
}
