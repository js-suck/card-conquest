import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:front/pages/tournaments_registration_screen.dart';
import 'package:front/service/tournament_service.dart';
import 'package:front/utils/custom_future_builder.dart';
import 'package:front/widget/app_bar.dart';
import 'package:front/widget/tournaments/all_tournaments_list.dart';
import 'package:front/widget/tournaments/recent_tournaments_list.dart';

import 'bracket_screen.dart';

class TournamentsPage extends StatefulWidget {
  const TournamentsPage({super.key});

  @override
  _TournamentsPageState createState() => _TournamentsPageState();
}

class _TournamentsPageState extends State<TournamentsPage> {
  late TournamentService tournamentService;

  @override
  void initState() {
    super.initState();
    tournamentService = TournamentService();
    tournamentService.fetchTournaments();
    tournamentService.fetchRecentTournaments();
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

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: TopAppBar(title: t.tournamentTitle),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                t.recentTournaments,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            CustomFutureBuilder(
              future: tournamentService.fetchRecentTournaments(),
              onLoaded: (tournaments) {
                return RecentTournamentsList(
                  recentTournaments: tournaments,
                  onTournamentTapped: _onTournamentTapped,
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                t.allTournaments,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            CustomFutureBuilder(
              future: tournamentService.fetchTournaments(),
              onLoaded: (tournaments) {
                return AllTournamentsList(
                  allTournaments: tournaments,
                  onTournamentTapped: _onTournamentTapped,
                  emptyMessage: t.noAvailableTournaments,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
