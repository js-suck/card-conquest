import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/models/guild.dart' as guild;
import 'package:http/http.dart' as http;

class GuildService {
  final storage = const FlutterSecureStorage();

  Future<guild.Guild> fetchGuild(int guildID) async {
    String? token = await storage.read(key: 'jwt_token');

    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}guilds/$guildID'),
      headers: {
        HttpHeaders.authorizationHeader: '$token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load match');
    }
    final Map<String, dynamic> responseJson = jsonDecode(response.body);
    return guild.Guild.fromJson(responseJson);
  }

  fetchUserGuild(int userID) async {
    String? token = await storage.read(key: 'jwt_token');

    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}guilds/user/$userID'),
      headers: {
        HttpHeaders.authorizationHeader: '$token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load guild for user');
    }

    final List<dynamic> responseBody = jsonDecode(response.body);
    return responseBody.map((json) => guild.Guild.fromJson(json)).toList();
  }

  Future<List<guild.Guild>> fetchGuilds() async {
    String? token = await storage
        .read(key: 'jwt_token');

    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}guilds'),
      headers: {
        HttpHeaders.authorizationHeader
            : '$token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load guilds');
    }

    final List<dynamic> responseJson = jsonDecode(response.body);
    return responseJson.map((json) => guild.Guild.fromJson(json)).toList();
  }

  Future<bool> joinGuild(String guildId, String userId, String token) async {
    final response = await http.post(
      Uri.parse('${dotenv.env['API_URL']}guilds/$guildId/users/$userId'),
      headers: {
        HttpHeaders.authorizationHeader: '$token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> createGuild(String token, String userId, String name, String description) async {
    final response = await http.post(
      Uri.parse('${dotenv.env['API_URL']}guilds'),
      headers: {
        HttpHeaders.authorizationHeader: '$token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> leaveGuild(String guildId, String userId) async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.delete(
      Uri.parse('${dotenv.env['API_URL']}guilds/$guildId/users/$userId'),
      headers: {
        HttpHeaders.authorizationHeader: '$token',
      },
    );

    if (response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }



}
