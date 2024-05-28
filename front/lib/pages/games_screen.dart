import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/models/game.dart';
import 'package:front/widget/app_bar.dart';
import 'package:front/widget/games/games_list.dart';
import 'package:front/widget/games/all_games_list.dart';
import 'package:http/http.dart' as http;

Future<List<Game>> fetchGames() async {
  final storage = new FlutterSecureStorage();
  String? token = await storage.read(key: 'jwt_token');

  final response = await http.get(
    Uri.parse('${dotenv.env['API_URL']}games'),
    headers: {
      HttpHeaders.authorizationHeader: '$token',
    },
  );

  final List<dynamic> responseJson = jsonDecode(response.body) as List<dynamic>;

  return responseJson.map((json) => Game.fromJson(json)).toList();
}

class Game {
  final String name;

  Game({
    required this.name,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'name': String name,
      } =>
        Game(
          name: name,
        ),
      _ => throw const FormatException('Failed to load game.'),
    };
  }
}
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  _GamesPageState createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  List<Game> games = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    String? token = await _storage.read(key: 'jwt_token');
    final gamesResponse = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/v1/games'),
      headers: {
        'Authorization': '$token',
      },
    );

    if (gamesResponse.statusCode == 200) {
      final responseData = jsonDecode(gamesResponse.body);

      setState(() {
        games = (responseData as List)
            .map((data) => Game.fromJson(data))
            .toList();
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load games');
    }
  }

  Future<void> _onGameTapped(int id) async {
    // Logique pour gérer le tap sur un jeu, par exemple naviguer vers une page de détails
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(title: 'Jeux'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Jeux populaires',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            GamesList(games: games),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Tous les jeux',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            AllGamesList(
              allGames: games,
              onGameTapped: _onGameTapped,
            ),

          ],
        ),
      ),
    );
  }
}
