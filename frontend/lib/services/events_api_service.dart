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

  Future<List<AppEvent>> getMyEvents({
    required String token,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/events/my');

    final http.Response response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      throw Exception(
        data['detail'] ?? 'Nie udało się pobrać Twoich wydarzeń',
      );
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
      final Map<String, dynamic> data = jsonDecode(response.body);

      throw Exception(
        data['detail'] ?? 'Nie udało się pobrać szczegółów wydarzenia',
      );
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    return AppEvent.fromJson(data);
  }

  Future<AppEvent> createEvent({
    required String token,
    required String title,
    required String description,
    required String activityType,
    required String city,
    required String locationName,
    required String date,
    required String time,
    required String maxParticipants,
    required String level,
    required String ageMin,
    required String ageMax,
    required bool isPublic,
    required String groupId,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/events');

    final int? parsedMaxParticipants = int.tryParse(maxParticipants.trim());
    final int? parsedAgeMin = int.tryParse(ageMin.trim());
    final int? parsedAgeMax = int.tryParse(ageMax.trim());
    final int? parsedGroupId = int.tryParse(groupId.trim());

    if (parsedMaxParticipants == null) {
      throw Exception('Limit uczestników musi być liczbą');
    }

    final Map<String, dynamic> body = {
      'title': title.trim(),
      'description': description.trim(),
      'activity_type': activityType.trim(),
      'city': city.trim(),
      'location_name': locationName.trim(),
      'date': date.trim(),
      'time': time.trim(),
      'max_participants': parsedMaxParticipants,
      'level': level.trim(),
      'age_min': parsedAgeMin,
      'age_max': parsedAgeMax,
      'is_public': isPublic,
      'group_id': parsedGroupId,
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
        data['detail'] ?? 'Nie udało się utworzyć wydarzenia',
      );
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    return AppEvent.fromJson(data);
  }

  Future<AppEvent> updateEvent({
    required String token,
    required int eventId,
    required String title,
    required String description,
    required String activityType,
    required String city,
    required String locationName,
    required String date,
    required String time,
    required String maxParticipants,
    required String level,
    required String ageMin,
    required String ageMax,
    required bool isPublic,
    required String groupId,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/events/$eventId');

    final int? parsedMaxParticipants = int.tryParse(maxParticipants.trim());
    final int? parsedAgeMin = int.tryParse(ageMin.trim());
    final int? parsedAgeMax = int.tryParse(ageMax.trim());
    final int? parsedGroupId = int.tryParse(groupId.trim());

    if (parsedMaxParticipants == null) {
      throw Exception('Limit uczestników musi być liczbą');
    }

    final Map<String, dynamic> body = {
      'title': title.trim(),
      'description': description.trim(),
      'activity_type': activityType.trim(),
      'city': city.trim(),
      'location_name': locationName.trim(),
      'date': date.trim(),
      'time': time.trim(),
      'max_participants': parsedMaxParticipants,
      'level': level.trim(),
      'age_min': parsedAgeMin,
      'age_max': parsedAgeMax,
      'is_public': isPublic,
      'group_id': parsedGroupId,
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
        data['detail'] ?? 'Nie udało się zaktualizować wydarzenia',
      );
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    return AppEvent.fromJson(data);
  }

  Future<void> deleteEvent({
    required int eventId,
    required String token,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/events/$eventId');

    final http.Response response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      throw Exception(
        data['detail'] ?? 'Nie udało się usunąć wydarzenia',
      );
    }
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

      throw Exception(
        data['detail'] ?? 'Nie udało się dołączyć do wydarzenia',
      );
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

      throw Exception(
        data['detail'] ?? 'Nie udało się opuścić wydarzenia',
      );
    }
  }
}