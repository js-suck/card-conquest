import 'package:flutter/material.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/generated/tournament.pb.dart';
import 'package:front/grpc/tournament_client.dart';
import 'package:front/utils/custom_future_builder.dart';
import 'package:front/widget/bracket/bracket.dart';
import 'package:front/widget/bracket/calendar.dart';
import 'package:front/widget/bracket/results.dart';
import 'package:front/widget/bracket/scoreboard.dart';
import 'package:provider/provider.dart';

import '../models/match/tournament.dart';
import '../service/tournament_service.dart';
import '../utils/custom_stream_builder.dart';

class BracketPage extends StatefulWidget {
  final int tournamentID;

  const BracketPage({super.key, required this.tournamentID});

  @override
  State<BracketPage> createState() => _BracketPageState();
}

class _BracketPageState extends State<BracketPage> {
  final isBracket = true;
  late TournamentClient tournamentClient;
  late TournamentService tournamentService;

  @override
  void initState() {
    super.initState();
    tournamentClient = TournamentClient();
    tournamentClient.subscribeTournamentUpdate(widget.tournamentID);
    tournamentService = TournamentService();
    tournamentService.fetchTournament(widget.tournamentID);
  }

  @override
  void dispose() {
    tournamentClient.shutdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          title: const Text(
            'Tableau',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              color: Colors.white,
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            )
          ],
          bottom: TabBar(
            labelColor: context.themeColors.accentColor,
            indicatorColor: context.themeColors.accentColor,
            unselectedLabelColor: Colors.white,
            tabs: [
              isBracket
                  ? const Tab(text: 'Tableau')
                  : const Tab(text: 'Classement'),
              const Tab(text: 'Résultats'),
              const Tab(text: 'Calendrier'),
            ],
          ),
        ),
        body: CustomStreamBuilder<TournamentResponse>(
            stream:
                tournamentClient.subscribeTournamentUpdate(widget.tournamentID),
            onLoaded: (tournamentStream) {
              return CustomFutureBuilder(
                future: tournamentService.fetchTournament(widget.tournamentID),
                onLoaded: (tournament) {
                  context.read<TournamentNotifier>().setTournament(tournament);
                  return Column(
                    children: [
                      Expanded(
                        child: TabBarView(
                          children: [
                            isBracket
                                ? Bracket(tournamentStream)
                                : Scoreboard(),
                            Results(tournamentId: widget.tournamentID),
                            Calendar(tournamentId: widget.tournamentID),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            }),
      ),
    );
  }
}

class TournamentNotifier extends ChangeNotifier {
  Tournament? _tournament;

  Tournament? get tournament => _tournament;

  void setTournament(Tournament tournament) {
    _tournament = tournament;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
