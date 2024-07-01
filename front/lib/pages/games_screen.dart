import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:front/service/game_service.dart';
import 'package:front/utils/custom_future_builder.dart';
import 'package:front/widget/app_bar.dart';
import 'package:front/widget/games/all_games_list.dart';
import 'package:front/widget/games/games_list.dart';

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
    var t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: TopAppBar(title: t.gamesTitle),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                t.gamesPopular,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            CustomFutureBuilder(
                future: gameService.fetchTrendyGames(),
                onLoaded: (games) {
                  return GamesList(games: games);
                }),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                t.gamesAll,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
