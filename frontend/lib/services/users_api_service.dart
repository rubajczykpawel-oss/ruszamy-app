import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/user_profile.dart';

class UsersApiService {
  Future<List<UserProfile>> searchUsers({
    required String token,
    required String username,
  }) async {
    final Uri url = Uri.parse(
      '${ApiConfig.baseUrl}/users/search?username=${Uri.encodeComponent(username.trim())}',
    );

    final http.Response response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      throw Exception(
        data['detail'] ?? 'Nie udało się wyszukać użytkowników',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data.map((item) {
      return UserProfile.fromJson(item);
    }).toList();
  }

  Future<UserProfile> updateMyProfile({
    required String token,
    required String username,
    required String city,
    required String age,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/users/me');

    final int? parsedAge = int.tryParse(age.trim());

    final Map<String, dynamic> body = {
      'username': username.trim(),
      'city': city.trim(),
      'age': parsedAge,
    };

    final http.Response response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      throw Exception(
        data['detail'] ?? 'Nie udało się zaktualizować profilu',
      );
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    return UserProfile.fromJson(data);
  }
}