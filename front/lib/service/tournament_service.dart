import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/models/match/tournament.dart';
import 'package:front/models/tournament_home.dart';
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

  Future<List<Tournament>> fetchTournaments() async {
    String? token = await storage.read(key: 'jwt_token');

    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}tournaments'),
      headers: {
        HttpHeaders.authorizationHeader: '$token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load tournaments');
    }
    final List<dynamic> responseJson = jsonDecode(response.body);
    return responseJson.map((json) => Tournament.fromJson(json)).toList();
  }

  Future<List<TournamentHome>> fetchRecentTournaments() async {
    String? token = await storage.read(key: 'jwt_token');

    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}tournaments?WithRecents=true'),
      headers: {
        HttpHeaders.authorizationHeader: '$token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load recent tournaments');
    }
    final Map<String, dynamic> responseJson = jsonDecode(response.body);
    final List<dynamic> recentTournamentsJson =
    responseJson['recentTournaments'];
    return recentTournamentsJson
        .map((json) => TournamentHome.fromJson(json))
        .toList();
  }

  Future<List<Tournament>> fetchUpcomingTournamentsOfUser(int userId) async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}tournaments?UserID=$userId'),
      headers: {
        'Authorization': '$token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load upcoming tournaments');
    }

    List<dynamic>? tournaments = jsonDecode(response.body);
    if (tournaments == null) {
      return [];
    }

    List<Tournament> upcomingTournaments = [];
    for (var tournament in tournaments) {
      Tournament tournamentObj = Tournament.fromJson(tournament);
      if (tournamentObj.status == 'opened' || tournamentObj.status == 'started') {
        upcomingTournaments.add(tournamentObj);
      }
    }

    return upcomingTournaments;
  }

  Future<List<Tournament>> fetchPastTournamentsOfUser(int userId) async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}tournaments?UserID=$userId'),
      headers: {
        'Authorization': '$token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load past tournaments');
    }

    List<dynamic>? tournaments = jsonDecode(response.body);
    if (tournaments == null) {
      return [];
    }

    List<Tournament> pastTournaments = [];
    for (var tournament in tournaments) {
      Tournament tournamentObj = Tournament.fromJson(tournament);
      if (tournamentObj.status == 'finished' || tournamentObj.status == 'canceled') {
        pastTournaments.add(tournamentObj);
      }
    }

    return pastTournaments;
  }

  Future<List<Tournament>> fetchTournamentsByGameId(int gameId) async {
    String? token = await storage.read(key: 'jwt_token');

    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}tournaments?GameID=$gameId&Sort=start_date'),
      headers: {
        HttpHeaders.authorizationHeader: '$token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load tournaments');
    }
    final List<dynamic> responseJson = jsonDecode(response.body);
    if(responseJson == null){
      return [];
    }
    return responseJson.map((json) => Tournament.fromJson(json)).toList();
  }

  Future<void> subscribeToTournament(int userId, int tournamentId) async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.post(
      Uri.parse('${dotenv.env['API_URL']}users/subscriptions/$userId/tournaments/$tournamentId/subscribe'),
      headers: {
        HttpHeaders.authorizationHeader: '$token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to subscribe to tournament');
    }
  }

  Future<void> unsubscribeFromTournament(int userId, int tournamentId) async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.post(
      Uri.parse('${dotenv.env['API_URL']}users/subscriptions/$userId/tournaments/$tournamentId/unsubscribe'),
      headers: {
        HttpHeaders.authorizationHeader: '$token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to unsubscribe from tournament');
    }
  }

  Future<List<Tournament>> fetchSubscribedTournaments(int userId) async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}users/subscriptions/$userId/tournaments'),
      headers: {
        HttpHeaders.authorizationHeader: '$token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load subscribed tournaments');
    }
    final List<dynamic> responseJson = jsonDecode(response.body);
    return responseJson.map((json) => Tournament.fromJson(json)).toList();
  }
}
