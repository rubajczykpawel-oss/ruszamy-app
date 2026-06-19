import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/user_profile.dart';

class AuthApiService {
  String getErrorDetail(http.Response response) {
    try {
      final dynamic decodedBody = jsonDecode(response.body);

      if (decodedBody is Map<String, dynamic>) {
        final dynamic detail = decodedBody['detail'];

        if (detail is String) {
          return detail;
        }

        return detail.toString();
      }

      return response.body;
    } catch (_) {
      return response.body;
    }
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final http.Response response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> decodedBody = jsonDecode(response.body);

      final dynamic token = decodedBody['access_token'];

      if (token is String && token.isNotEmpty) {
        return token;
      }

      throw Exception('Backend nie zwrócił tokenu access_token.');
    }

    throw Exception(getErrorDetail(response));
  }

  Future<UserProfile> register({
    required String email,
    required String username,
    required String password,
    String? city,
    int? age,
  }) async {
    final http.Response response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'username': username,
        'password': password,
        'city': city,
        'age': age,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> decodedBody = jsonDecode(response.body);

      return UserProfile.fromJson(decodedBody);
    }

    throw Exception(getErrorDetail(response));
  }

  Future<UserProfile> getCurrentUser({
    required String token,
  }) async {
    final http.Response response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/auth/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> decodedBody = jsonDecode(response.body);

      return UserProfile.fromJson(decodedBody);
    }

    throw Exception(getErrorDetail(response));
  }
}