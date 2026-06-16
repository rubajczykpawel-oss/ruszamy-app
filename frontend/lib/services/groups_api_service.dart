import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/app_group.dart';
import '../models/group_member.dart';

class GroupsApiService {
  Future<List<AppGroup>> getMyGroups({
    required String token,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/groups/my');

    final http.Response response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      throw Exception(
        data['detail'] ?? 'Nie udało się pobrać Twoich grup',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data.map((item) {
      return AppGroup.fromJson(item);
    }).toList();
  }

  Future<AppGroup> getGroupDetails({
    required int groupId,
    required String token,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/groups/$groupId');

    final http.Response response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      throw Exception(
        data['detail'] ?? 'Nie udało się pobrać szczegółów grupy',
      );
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    return AppGroup.fromJson(data);
  }

  Future<List<GroupMember>> getGroupMembers({
    required int groupId,
    required String token,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/groups/$groupId/members');

    final http.Response response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      throw Exception(
        data['detail'] ?? 'Nie udało się pobrać członków grupy',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data.map((item) {
      return GroupMember.fromJson(item);
    }).toList();
  }

  Future<AppGroup> createGroup({
    required String token,
    required String name,
    required String description,
    required String city,
    required String activityType,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/groups');

    final Map<String, dynamic> body = {
      'name': name.trim(),
      'description': description.trim(),
      'city': city.trim(),
      'activity_type': activityType.trim(),
    };

    final http.Response response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      throw Exception(
        data['detail'] ?? 'Nie udało się utworzyć grupy',
      );
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    return AppGroup.fromJson(data);
  }

  Future<AppGroup> updateGroup({
    required String token,
    required int groupId,
    required String name,
    required String description,
    required String city,
    required String activityType,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/groups/$groupId');

    final Map<String, dynamic> body = {
      'name': name.trim(),
      'description': description.trim(),
      'city': city.trim(),
      'activity_type': activityType.trim(),
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
        data['detail'] ?? 'Nie udało się zaktualizować grupy',
      );
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    return AppGroup.fromJson(data);
  }

  Future<void> deleteGroup({
    required String token,
    required int groupId,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/groups/$groupId');

    final http.Response response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      throw Exception(
        data['detail'] ?? 'Nie udało się usunąć grupy',
      );
    }
  }

  Future<void> addMemberToGroup({
    required String token,
    required int groupId,
    required int userId,
  }) async {
    final Uri url = Uri.parse(
      '${ApiConfig.baseUrl}/groups/$groupId/members/$userId',
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
        data['detail'] ?? 'Nie udało się dodać użytkownika do grupy',
      );
    }
  }

  Future<void> removeMemberFromGroup({
    required String token,
    required int groupId,
    required int userId,
  }) async {
    final Uri url = Uri.parse(
      '${ApiConfig.baseUrl}/groups/$groupId/members/$userId',
    );

    final http.Response response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      if (response.body.isEmpty) {
        throw Exception('Nie udało się usunąć członka z grupy');
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      throw Exception(
        data['detail'] ?? 'Nie udało się usunąć członka z grupy',
      );
    }
  }
}