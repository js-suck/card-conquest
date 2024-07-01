import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/models/match/match.dart' as match;
import 'package:http/http.dart' as http;

import '../generated/match.pb.dart';

class MatchService {
  final storage = new FlutterSecureStorage();

  Future<List<match.Match>> fetchMatchesPlayerOne(PlayerMatch player) async {
    String? token = await storage.read(key: 'jwt_token');

    final response = await http.get(
      Uri.parse(
          '${dotenv.env['API_URL']}matchs?UserID=${player.id}&Status=finished'),
      headers: {
        HttpHeaders.authorizationHeader: '$token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load matches');
    }
    final List<dynamic> responseJson = jsonDecode(response.body);
    return responseJson.map((json) => match.Match.fromJson(json)).toList();
  }

  Future<List<match.Match>> fetchMatchesPlayerTwo(PlayerMatch player) async {
    String? token = await storage.read(key: 'jwt_token');

    final response = await http.get(
      Uri.parse(
          '${dotenv.env['API_URL']}matchs?UserID=${player.id}&Status=finished'),
      headers: {
        HttpHeaders.authorizationHeader: '$token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load matches');
    }
    final List<dynamic> responseJson = jsonDecode(response.body);
    return responseJson.map((json) => match.Match.fromJson(json)).toList();
  }

  Future<List<match.Match>> fetchMatchesHead2Head(
      PlayerMatch playerOne, PlayerMatch playerTwo) async {
    String? token = await storage.read(key: 'jwt_token');

    final response = await http.get(
      Uri.parse(
          '${dotenv.env['API_URL']}matchs/between-users?Player1ID=${playerOne.id}&PlayerID2=${playerTwo.id}&Status=finished'),
      headers: {
        HttpHeaders.authorizationHeader: '$token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load matches');
    }
    final List<dynamic> responseJson = jsonDecode(response.body);
    return responseJson.map((json) => match.Match.fromJson(json)).toList();
  }

  Future<match.Match> fetchMatch(int matchId) async {
    String? token = await storage.read(key: 'jwt_token');

    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}matchs/$matchId'),
      headers: {
        HttpHeaders.authorizationHeader: '$token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load match');
    }
    final Map<String, dynamic> responseJson = jsonDecode(response.body);
    return match.Match.fromJson(responseJson);
  }

  Future<List<match.Match>> fetchFinishedMatchesOfPlayer(playerId) async {
    String? token = await storage.read(key: 'jwt_token');

    final response = await http.get(
      Uri.parse(
          '${dotenv.env['API_URL']}matchs?UserID=$playerId&Status=finished'),
      headers: {
        HttpHeaders.authorizationHeader: '$token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load matches');
    }
    final List<dynamic> responseJson = jsonDecode(response.body);
    return responseJson.map((json) => match.Match.fromJson(json)).toList();
  }

  Future<List<match.Match>> fetchFinishedMatchesOfTournament(
      tournamentId) async {
    String? token = await storage.read(key: 'jwt_token');

    final response = await http.get(
      Uri.parse(
          '${dotenv.env['API_URL']}matchs?tournamentId=$tournamentId&Status=finished'),
      headers: {
        HttpHeaders.authorizationHeader: '$token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load matches');
    }
    final List<dynamic> responseJson = jsonDecode(response.body);
    return responseJson.map((json) => match.Match.fromJson(json)).toList();
  }

  Future<List<match.Match>> fetchUnfinishedMatchesOfTournament(
      tournamentId) async {
    String? token = await storage.read(key: 'jwt_token');

    final response = await http.get(
      Uri.parse(
          '${dotenv.env['API_URL']}matchs?tournamentId=$tournamentId&Unfinished=true'),
      headers: {
        HttpHeaders.authorizationHeader: '$token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load matches');
    }
    final List<dynamic> responseJson = jsonDecode(response.body);
    return responseJson.map((json) => match.Match.fromJson(json)).toList();
  }
}
