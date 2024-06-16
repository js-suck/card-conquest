import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/models/game.dart';
import 'package:http/http.dart' as http;

class GameService {
  final storage = new FlutterSecureStorage();

  Future<List<Game>> fetchGames() async {
    String? token = await storage.read(key: 'jwt_token');

    final gamesResponse = await http.get(
      Uri.parse('${dotenv.env['API_URL']}games'),
      headers: {HttpHeaders.authorizationHeader: '$token'},
    );

    if (gamesResponse.statusCode != 200) {
      throw Exception('Failed to load games');
    }
    final List<dynamic> responseJson = jsonDecode(gamesResponse.body);
    return responseJson.map((json) => Game.fromJson(json)).toList();
  }

  Future<List<Game>> fetchTrendyGames() async {
    String? token = await storage.read(key: 'jwt_token');

    final gamesResponse = await http.get(
      Uri.parse('${dotenv.env['API_URL']}games?WithTrendy=true'),
      headers: {HttpHeaders.authorizationHeader: '$token'},
    );

    if (gamesResponse.statusCode != 200) {
      throw Exception('Failed to load games');
    }
    final Map<String, dynamic> responseJson = jsonDecode(gamesResponse.body);
    final List<dynamic> trendyGamesJson = responseJson['trendyGames'];
    return trendyGamesJson.map((json) => Game.fromJson(json)).toList();
  }
}