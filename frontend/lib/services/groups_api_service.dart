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
}