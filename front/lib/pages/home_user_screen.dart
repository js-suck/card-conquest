import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/extension/theme_extension.dart';
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
import 'package:front/widget/tournaments/recent_tournaments_list.dart';
import 'package:provider/provider.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../providers/feature_flag_provider.dart';
import '../widget/bottom_bar.dart';
import 'game_detail_screen.dart';

class HomeUserPage extends StatefulWidget {
  const HomeUserPage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomeUserPage> {
  final storage = const FlutterSecureStorage();
  late TournamentService tournamentService;
  late GameService gameService;
  late bool isGuildEnabled;
  String userRole = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    tournamentService = TournamentService();
    gameService = GameService();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    await getUserRole();
    setState(() {
      isLoading = false;
    });
    tournamentService.fetchTournaments();
    tournamentService.fetchRecentTournaments();
    gameService.fetchGames();
  }

  Future<void> getUserRole() async {
    String? token = await storage.read(key: 'jwt_token');
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      setState(() {
        userRole = decodedToken['role'];
      });
    }
  }

  Future<void> _onTournamentTapped(int tournamentId, String status) async {
    Widget page;
    switch (status) {
      case 'opened':
        page = RegistrationPage(tournamentId: tournamentId);
        break;
      case 'started':
      case 'finished':
      case 'canceled':
        page = BracketPage(tournamentID: tournamentId);
        break;
      default:
        page = RegistrationPage(tournamentId: tournamentId);
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Future<void> _onTournamentPageTapped() async {
    final selectedPageModel = Provider.of<SelectedPageModel>(context, listen: false);
    selectedPageModel.changePage(const TournamentsPage(searchQuery: null), 1);
  }

  Future<void> _onGamePageTapped() async {
    final selectedPageModel = Provider.of<SelectedPageModel>(context, listen: false);
    selectedPageModel.changePage(const GamesPage(), 3);
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
    final featureNotifier = Provider.of<FeatureNotifier>(context, listen: false);
    isGuildEnabled = featureNotifier.isFeatureEnabled('guild');
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      floatingActionButton: isGuildEnabled && userRole != 'invite'
          ? FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/guild');
        },
        backgroundColor: context.themeColors.accentColor,
        child: const Icon(Icons.diversity_3),
      )
          : null,
      appBar: TopAppBar(title: t.homeTitle, isAvatar: true, isPage: false),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildSectionTitle(t.recentTournaments),
            CustomFutureBuilder(
              future: tournamentService.fetchRecentTournaments(),
              onLoaded: (tournaments) {
                return RecentTournamentsList(
                  recentTournaments: tournaments,
                  onTournamentTapped: (id, status) => _onTournamentTapped(id, status),
                );
              },
            ),
            _buildSectionTitleWithButton(
              t.homeTournaments,
              t.homeShowTournaments,
              _onTournamentPageTapped,
            ),
            CustomFutureBuilder(
              future: tournamentService.fetchTournaments(),
              onLoaded: (tournaments) {
                return AllTournamentsList(
                  allTournaments: tournaments.take(4).toList(),
                  onTournamentTapped: (id, status) => _onTournamentTapped(id, status),
                  emptyMessage: t.noUpcomingTournaments,
                );
              },
            ),
            _buildSectionTitleWithButton(
              t.homeGames,
              t.homeShowGames,
              _onGamePageTapped,
            ),
            CustomFutureBuilder(
              future: gameService.fetchGames(),
              onLoaded: (games) {
                return GamesList(
                  games: games.take(4).toList(),
                  onGameTapped: _onGameTapped,
                );
              },
            ),
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

  Widget _buildSectionTitleWithButton(String title, String buttonText, VoidCallback onPressed) {
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
