import 'package:flutter/material.dart';
import 'package:front/models/game.dart';
import 'package:front/widget/app_bar.dart';
import 'package:front/widget/games/games_list.dart';
import 'package:front/widget/games/all_games_list.dart';
import 'package:http/http.dart' as http;
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
