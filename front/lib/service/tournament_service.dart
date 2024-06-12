import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/models/match/tournament.dart';
import 'package:http/http.dart' as http;

class TournamentService {
  final storage = new FlutterSecureStorage();

  Future<Tournament> fetchTournament(int tournamentId) async {
    String? token = await storage.read(key: 'jwt_token');

    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}tournaments/$tournamentId'),
      headers: {
        HttpHeaders.authorizationHeader: '$token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load tournament');
    }
    final Map<String, dynamic> responseJson = jsonDecode(response.body);
    return Tournament.fromJson(responseJson);
  }
}
