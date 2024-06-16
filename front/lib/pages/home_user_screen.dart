import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/pages/bracket_screen.dart';
import 'package:front/pages/games_screen.dart';
import 'package:front/pages/tournaments_registration_screen.dart';
import 'package:front/pages/tournaments_screen.dart';
import 'package:front/service/game_service.dart';
import 'package:front/service/tournament_service.dart';
import 'package:front/utils/custom_future_builder.dart';
import 'package:front/widget/app_bar.dart';
import 'package:front/widget/games/games_list.dart';
import 'package:front/widget/tournaments/all_tournaments_list.dart';
import 'package:provider/provider.dart';

import '../widget/bottom_bar.dart';
import '../widget/tournaments/recent_tournaments_list.dart';

class HomeUserPage extends StatefulWidget {
  const HomeUserPage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomeUserPage> {
  final storage = const FlutterSecureStorage();
  late TournamentService tournamentService;
  late GameService gameService;

  @override
  void initState() {
    super.initState();
    tournamentService = TournamentService();
    gameService = GameService();
    tournamentService.fetchTournaments();
    tournamentService.fetchRecentTournaments();
    gameService.fetchGames();
  }

  Future<void> _onTournamentTapped(int tournamentId, String status) async {
    Widget page;
    switch (status) {
      case 'opened':
        page = RegistrationPage(tournamentId: tournamentId);
        break;
      case 'started':
        // Ajoutez un id pour la page bracket
        page = BracketPage(tournamentID: tournamentId);
        break;
      case 'finished':
        // Ajoutez un id pour la page bracket
        page = BracketPage(tournamentID: tournamentId);
        break;
      case 'canceled':
        // Ajoutez la page correspondante pour les tournois annulés
        page = BracketPage(tournamentID: tournamentId);
        break;
      default:
        page = RegistrationPage(
            tournamentId:
                tournamentId); // Par défaut, redirigez vers la page d'inscription
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Future<void> _onTournamentPageTapped() async {
    final selectedPageModel =
        Provider.of<SelectedPageModel>(context, listen: false);
    selectedPageModel.changePage(const TournamentsPage(), 1);
  }

  Future<void> _onGamePageTapped() async {
    final selectedPageModel =
        Provider.of<SelectedPageModel>(context, listen: false);
    selectedPageModel.changePage(const GamesPage(), 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(title: 'Accueil', isAvatar: true, isPage: false),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSectionTitle('Tournois récents'),
            CustomFutureBuilder(
                future: tournamentService.fetchRecentTournaments(),
                onLoaded: (tournaments) {
                  return RecentTournamentsList(
                    recentTournaments: tournaments,
                    onTournamentTapped: (id, status) =>
                        _onTournamentTapped(id, status),
                  );
                }),
            _buildSectionTitleWithButton('Les tournois', 'Voir les tournois',
                _onTournamentPageTapped as VoidCallback),
            CustomFutureBuilder(
                future: tournamentService.fetchTournaments(),
                onLoaded: (tournaments) {
                  return AllTournamentsList(
                    allTournaments: tournaments.take(4).toList(),
                    onTournamentTapped: (id, status) =>
                        _onTournamentTapped(id, status),
                    emptyMessage: 'Pas de tournois à venir',
                  );
                }),
            _buildSectionTitleWithButton(
                'Les jeux', 'Tous les jeux', _onGamePageTapped as VoidCallback),
            CustomFutureBuilder(
                future: gameService.fetchGames(),
                onLoaded: (games) {
                  return GamesList(games: games.take(4).toList());
                }),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSectionTitleWithButton(
      String title, String buttonText, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: onPressed,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}