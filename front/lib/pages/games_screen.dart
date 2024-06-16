import 'package:flutter/material.dart';
import 'package:front/utils/custom_future_builder.dart';
import 'package:front/widget/app_bar.dart';
import 'package:front/widget/games/all_games_list.dart';
import 'package:front/widget/games/games_list.dart';

import '../service/game_service.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  _GamesPageState createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  late GameService gameService;

  @override
  void initState() {
    super.initState();
    gameService = GameService();
    gameService.fetchGames();
    gameService.fetchTrendyGames();
  }

  Future<void> _onGameTapped(int id) async {
    // Logique pour gérer le tap sur un jeu, par exemple naviguer vers une page de détails
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(title: 'Jeux'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Jeux populaires',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            CustomFutureBuilder(
                future: gameService.fetchTrendyGames(),
                onLoaded: (games) {
                  return GamesList(games: games);
                }),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Tous les jeux',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            CustomFutureBuilder(
              future: gameService.fetchGames(),
              onLoaded: (games) {
                return AllGamesList(
                  allGames: games,
                  onGameTapped: _onGameTapped,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
