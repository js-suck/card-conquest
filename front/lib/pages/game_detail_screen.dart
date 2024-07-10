import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:front/models/game.dart';
import 'package:front/models/match/tournament.dart';
import 'package:front/pages/tournaments_registration_screen.dart';
import 'package:front/service/game_service.dart';
import 'package:front/service/tournament_service.dart';
import 'package:front/service/user_service.dart';
import 'package:front/widget/app_bar.dart';

import '../widget/bottom_bar.dart';
import '../widget/tournaments/all_tournaments_list.dart';
import 'bracket_screen.dart';

class GameDetailPage extends StatefulWidget {
  final int gameId;

  const GameDetailPage({Key? key, required this.gameId}) : super(key: key);

  @override
  _GameDetailPageState createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late GameService gameService;
  late TournamentService tournamentService;
  late UserService userService;
  Game? game;
  Map<String, dynamic>? userScore;
  List<Tournament> gameTournaments = [];
  bool isLoadingGame = true;
  bool isLoadingUserScore = true;
  bool isLoadingTournaments = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    gameService = GameService();
    tournamentService = TournamentService();
    userService = UserService();
    _fetchGameDetails();
    _fetchUserScore();
    _fetchGameTournaments();
  }

  Future<void> _fetchGameDetails() async {
    try {
      final fetchedGame = await gameService.fetchGameById(widget.gameId);
      setState(() {
        game = fetchedGame;
        isLoadingGame = false;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchUserScore() async {
    try {
      final score = await userService.fetchUserScoreForGame(widget.gameId);
      setState(() {
        userScore = score;
        isLoadingUserScore = false;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchGameTournaments() async {
    try {
      final tournaments = await tournamentService.fetchTournamentsByGameId(widget.gameId);
      setState(() {
        gameTournaments = tournaments.take(4).toList(); // Prendre les 4 premiers tournois
        isLoadingTournaments = false;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _onTournamentTapped(int tournamentId, String status) async {
    Widget page;
    switch (status) {
      case 'opened':
        page = RegistrationPage(tournamentId: tournamentId);
        break;
      case 'started':
        page = BracketPage(tournamentID: tournamentId);
        break;
      case 'finished':
        page = BracketPage(tournamentID: tournamentId);
        break;
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

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: TopAppBar(
          title: t.gameDetailsTitle,
          isAvatar: false,
        ),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: t.gameDetailsTab),
            Tab(text: t.gameScoreTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          isLoadingGame ? Center(child: CircularProgressIndicator()) : _buildGameDetails(),
          isLoadingUserScore ? Center(child: CircularProgressIndicator()) : _buildUserScore(),
        ],
      ),
    );
  }

  Widget _buildGameDetails() {
    var t = AppLocalizations.of(context)!;
    if (game == null) {
      return Center(child: Text(t.noGamesFound));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            game!.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: CachedNetworkImageProvider(game!.media?.fileName != null
                    ? '${dotenv.env['MEDIA_URL']}${game!.media?.fileName}'
                    : '${dotenv.env['MEDIA_URL']}yugiho.webp'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          isLoadingTournaments
              ? Center(child: CircularProgressIndicator())
              : AllTournamentsList(
            allTournaments: gameTournaments,
            onTournamentTapped: _onTournamentTapped,
            emptyMessage: t.noAvailableTournaments,
          ),
        ],
      ),
    );
  }
  Widget _buildUserScore() {
    var t = AppLocalizations.of(context)!;
    if (userScore == null) {
      return Center(child: Text(t.noUserScoreFound));
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                        userScore!['User']['media'] != null
                            ? userScore!['User']['media']['fileName']
                            : 'https://example.com/default_avatar.png'
                    ),
                    radius: 30,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    userScore!['User']['username'],
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildScoreCard(
                    icon: Icons.score,
                    label: t.score,
                    value: userScore!['Score'].toString(),
                  ),
                  _buildScoreCard(
                    icon: Icons.emoji_events,
                    label: t.rank,
                    value: userScore!['Rank'].toString(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard({required IconData icon, required String label, required String value}) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}





