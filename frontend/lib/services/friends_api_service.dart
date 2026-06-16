import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/friendship.dart';
import '../models/user_profile.dart';

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

  Future<List<Friendship>> getReceivedFriendRequests({
    required String token,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/friends/requests/received');

    final http.Response response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      throw Exception(
        data['detail'] ?? 'Nie udało się pobrać odebranych zaproszeń',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data.map((item) {
      return Friendship.fromJson(item);
    }).toList();
  }

  Future<List<Friendship>> getSentFriendRequests({
    required String token,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/friends/requests/sent');

    final http.Response response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      throw Exception(
        data['detail'] ?? 'Nie udało się pobrać wysłanych zaproszeń',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data.map((item) {
      return Friendship.fromJson(item);
    }).toList();
  }

  Future<List<UserProfile>> getMyFriends({
    required String token,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/friends');

    final http.Response response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      throw Exception(
        data['detail'] ?? 'Nie udało się pobrać znajomych',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data.map((item) {
      return UserProfile.fromJson(item);
    }).toList();
  }

  Future<void> acceptFriendRequest({
    required String token,
    required int friendshipId,
  }) async {
    final Uri url = Uri.parse(
      '${ApiConfig.baseUrl}/friends/accept/$friendshipId',
    );

    final http.Response response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      throw Exception(
        data['detail'] ?? 'Nie udało się zaakceptować zaproszenia',
      );
    }
  }

  Future<void> rejectFriendRequest({
    required String token,
    required int friendshipId,
  }) async {
    final Uri url = Uri.parse(
      '${ApiConfig.baseUrl}/friends/reject/$friendshipId',
    );

    final http.Response response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      throw Exception(
        data['detail'] ?? 'Nie udało się odrzucić zaproszenia',
      );
    }
  }
}