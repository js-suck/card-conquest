import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/widget/app_bar.dart';
import 'package:front/widget/game_card.dart';
import 'package:http/http.dart' as http;

Future<List<Game>> fetchGames() async {
  final storage = new FlutterSecureStorage();
  String? token = await storage.read(key: 'jwt_token');

  final response = await http.get(
    Uri.parse('http://10.0.2.2:8080/api/v1/games'),
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

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  late Future<List<Game>> futureGames;

  @override
  void initState() {
    super.initState();
    futureGames = fetchGames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(title: 'Jeux'),
      // list of cards with games
      body: Container(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Les jeux du moment',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(
                height: 180,
                child: GridView.count(
                  scrollDirection: Axis.horizontal,
                  crossAxisCount: 1,
                  children: List.generate(
                    10,
                    (index) {
                      return GameCard(
                        imageName: 'images/img.png',
                        gameName: 'Jeu $index',
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Tous les jeux',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(
                height: 540,
                child: FutureBuilder<List<Game>>(
                  future: futureGames,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return GridView.count(
                        scrollDirection: Axis.vertical,
                        crossAxisCount: 2,
                        children: List.generate(
                          snapshot.data!.length,
                          (index) {
                            return GameCard(
                              imageName: 'images/img.png',
                              gameName: snapshot.data![index].name,
                            );
                          },
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }

                    return const CircularProgressIndicator();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
