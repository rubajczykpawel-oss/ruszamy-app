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
}