import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:front/pages/game_detail_screen.dart';
import 'package:front/service/game_service.dart';
import 'package:front/utils/custom_future_builder.dart';
import 'package:front/widget/app_bar.dart';
import 'package:front/widget/games/all_games_list.dart';
import 'package:front/widget/games/games_list.dart';

import '../models/game.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  _GamesPageState createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  late GameService gameService;
  final TextEditingController _searchController = TextEditingController();
  List<Game> _allGames = [];
  List<Game> _filteredGames = [];
  List<Game> _trendyGames = [];

  @override
  void initState() {
    super.initState();
    gameService = GameService();
    _fetchGames();
    _fetchTrendyGames();
  }

  Future<void> _fetchGames() async {
    final games = await gameService.fetchGames();
    setState(() {
      _allGames = games;
      _filteredGames = games;
    });
  }

  Future<void> _fetchTrendyGames() async {
    final games = await gameService.fetchTrendyGames();
    setState(() {
      _trendyGames = games;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredGames = _allGames.where((game) {
        final gameName = game.name.toLowerCase();
        return gameName.contains(query);
      }).toList();
    });
  }

  Future<void> _onGameTapped(int id) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameDetailPage(gameId: id),
      ),
    );
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
                onLoaded: (List<Game> games) {
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => _onSearchChanged(),
                decoration: InputDecoration(
                  labelText: t.gamesSearchBar,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            _filteredGames.isEmpty
                ? Center(child: Text(t.noGamesFound))
                : AllGamesList(
                    allGames: _filteredGames,
                    onGameTapped: _onGameTapped,
                  ),
          ],
        ),
      ),
    );
  }
}
