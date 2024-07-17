import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:front/pages/tournaments_registration_screen.dart';
import 'package:front/service/tournament_service.dart';
import 'package:front/utils/custom_future_builder.dart';
import 'package:front/widget/app_bar.dart';
import 'package:front/widget/tournaments/all_tournaments_list.dart';
import 'package:front/widget/tournaments/recent_tournaments_list.dart';

import '../models/match/tournament.dart';
import 'bracket_screen.dart';

class TournamentsPage extends StatefulWidget {
  const TournamentsPage({super.key, required searchQuery});

  @override
  _TournamentsPageState createState() => _TournamentsPageState();
}

class _TournamentsPageState extends State<TournamentsPage> {
  late TournamentService tournamentService;
  List<Tournament> allTournaments = [];
  List<Tournament> filteredTournaments = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    tournamentService = TournamentService();
    _fetchTournaments();
  }

  Future<void> _fetchTournaments() async {
    var tournaments = await tournamentService.fetchTournaments();
    setState(() {
      allTournaments = tournaments;
      filteredTournaments = tournaments;
    });
  }

  Future<void> _onTournamentTapped(int tournamentId, String status) async {
    print('Tournament tapped: $tournamentId, status: $status');
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

  void _filterTournaments(String query) {
    final filtered = allTournaments.where((tournament) {
      final nameLower = tournament.name.toLowerCase();
      final searchLower = query.toLowerCase();
      return nameLower.contains(searchLower);
    }).toList();

    setState(() {
      searchQuery = query;
      filteredTournaments = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    return Scaffold(
        appBar: TopAppBar(
      title: t.tournamentTitle,
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.map,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/tournaments/map');
          },
        ),
      ],
    ),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: _filterTournaments,
                decoration: InputDecoration(
                  hintText: t.tournamentSearchBar,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            AllTournamentsList(
              allTournaments: filteredTournaments,
              onTournamentTapped: _onTournamentTapped,
              emptyMessage: t.noAvailableTournaments,
            ),
          ],
        ),
      ),
    );
  }
}
