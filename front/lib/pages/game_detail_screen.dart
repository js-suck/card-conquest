import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/models/game.dart';
import 'package:front/models/match/tournament.dart';
import 'package:front/pages/tournaments_registration_screen.dart';
import 'package:front/service/game_service.dart';
import 'package:front/service/tournament_service.dart';
import 'package:front/service/user_service.dart';
import 'package:front/widget/app_bar.dart';

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
  List<Map<String, dynamic>> userRankings = [];
  List<Tournament> gameTournaments = [];
  bool isLoadingGame = true;
  bool isLoadingUserRankings = true;
  bool isLoadingTournaments = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    gameService = GameService();
    tournamentService = TournamentService();
    userService = UserService();
    _fetchGameDetails();
    _fetchUserRankings();
    _fetchGameTournaments();
  }

  Future<void> _fetchGameDetails() async {
    try {
      final fetchedGame = await gameService.fetchGameById(widget.gameId);
      setState(() {
        game = fetchedGame;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoadingGame = false;
      });
    }
  }

  Future<void> _fetchUserRankings() async {
    try {
      final rankings = await gameService.fetchUserRankingsForGame(widget.gameId);
      setState(() {
        userRankings = rankings;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoadingUserRankings = false;
      });
    }
  }

  Future<void> _fetchGameTournaments() async {
    try {
      final tournaments = await tournamentService.fetchTournamentsByGameId(widget.gameId);
      setState(() {
        gameTournaments = tournaments.take(4).toList();
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoadingTournaments = false;
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
          labelColor: context.themeColors.accentColor,
          indicatorColor: context.themeColors.accentColor,
          unselectedLabelColor: Colors.white,
          tabs: [
            Tab(text: t.gameDetailsTab),
            Tab(text: t.gameScoreboardTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          isLoadingGame ? Center(child: CircularProgressIndicator()) : _buildGameDetails(),
          isLoadingUserRankings ? Center(child: CircularProgressIndicator()) : _buildUserRankings(),
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
      padding: const EdgeInsets.all(4.0),
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

  Widget _buildUserRankings() {
    var t = AppLocalizations.of(context)!;
    if (userRankings.isEmpty) {
      return Center(child: Text(t.noUserRankingsFound));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(4.0),
      itemCount: userRankings.length,
      itemBuilder: (context, index) {
        final user = userRankings[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user['User']['media'] == null
                ? '${dotenv.env['MEDIA_URL']}test.jpg'
                : '${dotenv.env['MEDIA_URL']}${user['User']['media']['fileName']}'),
          ),
          title: Text(user['User']['username']),
          subtitle: Text('Score: ${user['Score']}'),
          trailing: Text('#${user['Rank']}'),
        );
      },
    );
  }
}
