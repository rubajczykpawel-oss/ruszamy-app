import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/user_profile.dart';

class AuthApiService {
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/auth/login');

    final http.Response response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Nieprawidłowy e-mail lub hasło');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    return data['access_token'];
  }

  Future<UserProfile> getCurrentUser({
    required String token,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/auth/me');

    final http.Response response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Nie udało się pobrać profilu użytkownika');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    return UserProfile.fromJson(data);
  }
}