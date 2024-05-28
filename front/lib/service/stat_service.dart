import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/stat/stat.dart';

class StatService {
  final storage = new FlutterSecureStorage();

  Future<Stat> fetchStats(playerId) async {
    String? token = await storage.read(key: 'jwt_token');

    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}users/$playerId/stats'),
      headers: {
        HttpHeaders.authorizationHeader: '$token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load stats');
    }

    final responseJson = jsonDecode(response.body);
    return Stat.fromJson(responseJson);
  }
}
