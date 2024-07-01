import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/pages/bracket_screen.dart';
import 'package:front/pages/tournaments_registration_screen.dart';
import 'package:front/service/tournament_service.dart';
import 'package:front/utils/custom_future_builder.dart';
import 'package:front/widget/app_bar.dart';
import 'package:front/widget/tournaments/all_tournaments_list.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

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
    tournamentService.fetchPastTournamentsOfUser(userId);
    tournamentService.fetchUpcomingTournamentsOfUser(userId);
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
    var t = AppLocalizations.of(context)!;
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: TopAppBar(title: t.tournamentHistoryTitle),
          automaticallyImplyLeading: false,
          bottom: TabBar(
            isScrollable: true,
            labelColor: context.themeColors.accentColor,
            indicatorColor: context.themeColors.accentColor,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: t.tournamentHistoryUpcoming),
              Tab(text: t.tournamentHistoryPast),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CustomFutureBuilder(
                future:
                    tournamentService.fetchUpcomingTournamentsOfUser(userId),
                onLoaded: (upcomingTournaments) {
                  return AllTournamentsList(
                    allTournaments: upcomingTournaments,
                    onTournamentTapped: _onTournamentTapped,
                    emptyMessage: t.noUpcomingTournaments,
                  );
                }),
            CustomFutureBuilder(
                future: tournamentService.fetchPastTournamentsOfUser(userId),
                onLoaded: (pastTournaments) {
                  return AllTournamentsList(
                    allTournaments: pastTournaments,
                    onTournamentTapped: _onTournamentTapped,
                    emptyMessage: t.noPastTournaments,
                  );
                }),
          ],
        ),
      ),
    );
  }
}
