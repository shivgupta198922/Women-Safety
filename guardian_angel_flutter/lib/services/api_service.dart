import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  static const storage = FlutterSecureStorage();

  static Future<String?> getToken() async {
    return await storage.read(key: 'jwt_token');
  }

  static setToken(String token) async {
    await storage.write(key: 'jwt_token', value: token);
  }

  static clearToken() async {
    await storage.delete(key: 'jwt_token');
  }

  static Future<http.Response> get(String endpoint, {Map<String, String>? headers}) async {
    final token = await getToken();
    headers ??= {};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> data, {bool auth = true}) async {
    final token = auth ? await getToken() : null;
    final headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return http.post(Uri.parse('$baseUrl$endpoint'), headers: headers, body: json.encode(data));
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    return http.put(Uri.parse('$baseUrl$endpoint'), headers: headers, body: json.encode(data));
  }

  static Future<http.Response> delete(String endpoint) async {
    final token = await getToken();
    final headers = {
      'Authorization': 'Bearer $token',
    };
    return http.delete(Uri.parse('$baseUrl$endpoint'), headers: headers);
  }
}
