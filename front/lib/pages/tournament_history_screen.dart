import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/pages/tournaments_registration_screen.dart';
import 'package:front/widget/app_bar.dart';
import 'package:front/widget/tournaments/all_tournaments_list.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../service/tournament_service.dart';
import '../utils/custom_future_builder.dart';
import 'bracket_screen.dart';

class TournamentHistoryPage extends StatefulWidget {
  const TournamentHistoryPage({super.key});

  @override
  _TournamentHistoryPageState createState() => _TournamentHistoryPageState();
}

class _TournamentHistoryPageState extends State<TournamentHistoryPage>
    with SingleTickerProviderStateMixin {
  final storage = const FlutterSecureStorage();
  int userId = 0;
  late TournamentService tournamentService;

  @override
  void initState() {
    super.initState();
    tournamentService = TournamentService();
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    String? token = await storage.read(key: 'jwt_token');
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      userId = decodedToken['user_id'];
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const TopAppBar(title: 'Historique'),
          automaticallyImplyLeading: false,
          bottom: TabBar(
            labelColor: context.themeColors.accentColor,
            indicatorColor: context.themeColors.accentColor,
            unselectedLabelColor: Colors.white,
            tabs: const [
              Tab(text: 'Tournois à venir'),
              Tab(text: 'Tournois Passés'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              child: CustomFutureBuilder(
                future: tournamentService.fetchUpcomingTournamentsOfUser(userId),
                onLoaded: (upcomingTournaments) {
                  return AllTournamentsList(
                    allTournaments: upcomingTournaments,
                    onTournamentTapped: _onTournamentTapped,
                    emptyMessage: 'Pas de tournois à venir',
                  );
                },
              ),
            ),
            SingleChildScrollView(
              child: CustomFutureBuilder(
                future: tournamentService.fetchPastTournamentsOfUser(userId),
                onLoaded: (pastTournaments) {
                  return AllTournamentsList(
                    allTournaments: pastTournaments,
                    onTournamentTapped: _onTournamentTapped,
                    emptyMessage: 'Pas de tournois passés',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
