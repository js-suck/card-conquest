import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../utils/shared_pref_cached_data.dart';

class UserService {
  final storage = const FlutterSecureStorage();
  final MySharedPreferences mySharedPreferences = MySharedPreferences();

  Future<User> fetchUser(int userId) async {
    try {
      final String? jsonData = await mySharedPreferences.getDataIfNotExpired();
      if (jsonData != null) {
        final Map<String, dynamic> responseJson = jsonDecode(jsonData);
        return User.fromJson(responseJson);
      } else {
        String? token = await storage.read(key: 'jwt_token');
        final response = await http.get(
          Uri.parse('${dotenv.env['API_URL']}users/$userId'),
          headers: {
            'Authorization': '$token',
          },
        );
        if (response.statusCode != 200) {
          throw Exception('Failed to load data');
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
      }
    } catch (error) {
      throw Exception(error);
    }
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
}
