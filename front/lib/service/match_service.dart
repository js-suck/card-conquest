import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/models/match/match.dart' as match;
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  Future<void> updateMatchLocation(int matchId, String location) async {
    final token = await storage.read(key: 'jwt_token');
    final response = await http.put(
      Uri.parse('${dotenv.env['API_URL']}matchs/$matchId'),
      headers: {
        'Authorization': '$token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'location': location}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update location');
    }
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
    print(responseJson);
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
          '${dotenv.env['API_URL']}matchs?TournamentID=$tournamentId&Status=finished'),
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
          '${dotenv.env['API_URL']}matchs?TournamentID=$tournamentId&Unfinished=true'),
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

  Future<List<match.Match>> fetchMatchesOfTournamentOfPlayer(
      tournamentId) async {
    String? token = await storage.read(key: 'jwt_token');
    String? userId = await storage.read(key: 'user_id');
    // retrieve id of the current user

    final response = await http.get(
      Uri.parse(
          '${dotenv.env['API_URL']}matchs?TournamentID=$tournamentId&UserID=$userId'),
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

  Future<void> updateMatchInfo(
      BuildContext context, int matchId, String location) async {
    final token = await storage.read(key: 'jwt_token');
    final t = AppLocalizations.of(context)!;

    var data = {
      'location': location,
    };
    var response = await http.put(
      Uri.parse('${dotenv.env['API_URL']}bracket/matchs/$matchId'),
      headers: {
        HttpHeaders.authorizationHeader: '$token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Location updated successfully');
      print(response.statusCode);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.successLocationUpdate),
        ),
      );
    } else {
      print('Failed to update location');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.failedLocationUpdate),
        ),
      );
    }
  }

  Future<void> updateScore(int matchId, int userId, int score) async {
    final url = '${dotenv.env['API_URL']}matchs/update/score';
    final token = await storage.read(key: 'jwt_token');
    var request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers['Authorization'] = '$token'
      ..fields['matchId'] = matchId.toString()
      ..fields['userId'] = userId.toString()
      ..fields['score'] = score.toString();

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Score updated successfully');
    } else {
      print('Failed to update score');
      print(response.statusCode);
      var responseData = await response.stream.bytesToString();
      print(responseData);
    }
  }

  Future<void> updateTimeMatch(BuildContext context, int matchId,
      String widgetStartTime, String time) async {
    final t = AppLocalizations.of(context)!;
    final token = await storage.read(key: 'jwt_token');
    DateTime originalDateTime = DateTime.parse(widgetStartTime);

    List<String> timeParts = time.split(':');
    int newHour = int.parse(timeParts[0]);
    int newMinute = int.parse(timeParts[1]);
    DateTime updatedDateTime = DateTime(
      originalDateTime.year,
      originalDateTime.month,
      originalDateTime.day,
      newHour,
      newMinute,
    );
    String formattedDateTime = updatedDateTime.toIso8601String();
    formattedDateTime = formattedDateTime.replaceFirst('.000', '.00Z');

    var data = {
      'startTime': formattedDateTime,
    };

    var response = await http.put(
      Uri.parse('${dotenv.env['API_URL']}bracket/matchs/$matchId'),
      headers: {
        HttpHeaders.authorizationHeader: '$token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.successTimeUpdate),
        ),
      );
    } else {
      print('Failed to update start time');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.failTimeUpdate),
        ),
      );
    }
  }

  bool isAdmin(String? jwtToken) {
    if (jwtToken == null) {
      return false;
    }
    Map<String, dynamic>? decodedToken = JwtDecoder.decode(jwtToken);

    if (!decodedToken.containsKey('role')) {
      return false;
    }

    return decodedToken['role'] == 'organizer';
  }

  bool isAdminWithDecodedToken(Map<String, dynamic> decodedToken) {
    return decodedToken['role'] == 'organizer';
  }
}
