import 'package:flutter/material.dart';
import 'package:front/utils/custom_future_builder.dart';
import 'package:front/widget/app_bar.dart';
import 'package:front/widget/games/all_games_list.dart';
import 'package:front/widget/games/games_list.dart';
import '../service/game_service.dart';
import '../models/game.dart';
import 'package:front/pages/game_detail_screen.dart';

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
                onLoaded: (List<Game> games) {
                  return GamesList(games: games);
                }),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Tous les jeux',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => _onSearchChanged(),
                decoration: InputDecoration(
                  labelText: 'Rechercher des jeux',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            _filteredGames.isEmpty
                ? const Center(child: Text('No games found'))
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
