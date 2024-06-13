import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class UserService {
  final String baseUrl;
  final storage = const FlutterSecureStorage();


  UserService(this.baseUrl);

  Future<Map<String, dynamic>> getUser(int userId) async {
    String? token = await storage.read(key: 'jwt_token');

    final response = await http.get(Uri.parse('$baseUrl/users/$userId'),
      headers: {
      'Authorization': '$token',
    }, );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user');
    }
  }
  Future<String?> getUserImage(int userId) async {
    final user = await getUser(userId);
    return user['media']?['url']; // Assurez-vous que le chemin vers l'URL de l'image est correct
  }
}
