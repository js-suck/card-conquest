import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/models/match/tournament.dart';
import 'package:front/models/tournament_home.dart';
import 'package:http/http.dart' as http;

class TournamentService {
  final storage = new FlutterSecureStorage();

  Future<Tournament> fetchTournament(int id) async {
    String? token = await storage.read(key: 'jwt_token');

    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}tournaments/$id'),
      headers: {
        'Authorization': '$token',
      },
    );
    if (response.statusCode == 200) {
      return Tournament.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load tournament');
    }
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
    List<Tournament> upcomingTournaments = [];
    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}tournaments/?UserId=$userId'),
      headers: {
        'Authorization': '$token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load upcoming tournaments');
    }
    List<dynamic> tournaments = json.decode(response.body);
    for (var tournament in tournaments) {
      Tournament tournamentObj = Tournament.fromJson(tournament);
      if (tournamentObj.status == 'opened' ||
          tournamentObj.status == 'started') {
        upcomingTournaments.add(tournamentObj);
      }
    }
    return upcomingTournaments;
  }

  Future<List<Tournament>> fetchPastTournamentsOfUser(int userId) async {
    String? token = await storage.read(key: 'jwt_token');
    List<Tournament> pastTournaments = [];
    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}tournaments/?UserId=$userId'),
      headers: {
        'Authorization': '$token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load upcoming tournaments');
    }
    List<dynamic> tournaments = json.decode(response.body);
    for (var tournament in tournaments) {
      Tournament tournamentObj = Tournament.fromJson(tournament);
      if (tournamentObj.status == 'finished' ||
          tournamentObj.status == 'canceled') {
        pastTournaments.add(tournamentObj);
      }
    }
    return pastTournaments;
  }
}
