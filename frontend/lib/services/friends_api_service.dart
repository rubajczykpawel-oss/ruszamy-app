import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class FriendsApiService {
  Future<void> sendFriendRequest({
    required String token,
    required int userId,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/friends/request/$userId');

    final http.Response response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      throw Exception(
        data['detail'] ?? 'Nie udało się wysłać zaproszenia do znajomych',
      );
    }
  }
}