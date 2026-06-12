import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/app_event.dart';

class EventsApiService {
  Future<List<AppEvent>> getPublicEvents() async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/events');

    final http.Response response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Nie udało się pobrać wydarzeń');
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data.map((item) {
      return AppEvent.fromJson(item);
    }).toList();
  }

  Future<AppEvent> getEventDetails({
    required int eventId,
    required String token,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/events/$eventId');

    final http.Response response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Nie udało się pobrać szczegółów wydarzenia');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    return AppEvent.fromJson(data);
  }

  Future<void> joinEvent({
    required int eventId,
    required String token,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/events/$eventId/join');

    final http.Response response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? 'Nie udało się dołączyć do wydarzenia');
    }
  }

  Future<void> leaveEvent({
    required int eventId,
    required String token,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/events/$eventId/leave');

    final http.Response response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? 'Nie udało się opuścić wydarzenia');
    }
  }
}