import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/models/stat/ranking.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../utils/shared_pref_cached_data.dart';

class UserService {
  final storage = const FlutterSecureStorage();
  final MySharedPreferences mySharedPreferences = MySharedPreferences();

  Future<User> fetchUser(int userId, {bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final String? jsonData = await mySharedPreferences.getDataIfNotExpired();
        if (jsonData != null) {
          final Map<String, dynamic> responseJson = jsonDecode(jsonData);
          return User.fromJson(responseJson);
        }
      }

      // If forceRefresh is true or cache is expired
      String? token = await storage.read(key: 'jwt_token');
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}users/$userId'),
        headers: {
          'Authorization': '$token',
        },
      );
      if (response.statusCode != 200) {
        return User.fromJson({
          "username": "Invité",
          "role": "invite",
        });
      } else {
        final isSaved = await mySharedPreferences.saveDataWithExpiration(
            response.body, const Duration(days: 10));
        if (isSaved) {
          final Map<String, dynamic> responseJson = jsonDecode(response.body);
          return User.fromJson(responseJson);
        } else {
          throw Exception('Failed to save data');
        }
      }
    } catch (error) {
      throw Exception(error);
    }
  }


  Future<List<Ranking>> fetchRanking() async {
    String? token = await storage.read(key: 'jwt_token');

    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}users/ranks'),
      headers: {
        HttpHeaders.authorizationHeader: '$token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load recent tournaments');
    }
    final List<dynamic> responseJson = jsonDecode(response.body);
    return responseJson.map((json) => Ranking.fromJson(json)).toList();
  }

  Future<User?> fetchUserBis(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    userId = 1;
    if (prefs.getString('user') == null) {
      String? token = await storage.read(key: 'jwt_token');

      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}users/$userId'),
        headers: {
          'Authorization': '$token',
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to load user');
      }
      final Map<String, dynamic> responseJson = jsonDecode(response.body);
      User user = User.fromJson(responseJson);
      prefs.setString('user', responseJson.toString());
      return user;
    } else {
      final Map<String, dynamic> responseJson =
          jsonDecode(prefs.getString('user')!);
      User user = User.fromJson(responseJson);
      return user;
    }
  }

  Future<Map<String, dynamic>> fetchUserScoreForGame(int gameId) async {
    String? token = await storage.read(key: 'jwt_token');

    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}games/user/$gameId/rankings'),
      headers: {
        HttpHeaders.authorizationHeader: '$token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load user score');
    }

    final List<dynamic> responseJson = jsonDecode(response.body);
    return responseJson.isNotEmpty ? responseJson[0] : {};
  }
}
