import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/generated/tournament.pb.dart';
import 'package:front/grpc/tournament_client.dart';
import 'package:front/models/match/tournament.dart';
import 'package:front/service/tournament_service.dart';
import 'package:front/utils/custom_future_builder.dart';
import 'package:front/utils/custom_stream_builder.dart';
import 'package:front/widget/bracket/bracket.dart';
import 'package:front/widget/bracket/calendar.dart';
import 'package:front/widget/bracket/results.dart';
import 'package:front/widget/bracket/scoreboard.dart';
import 'package:provider/provider.dart';
import 'package:front/widget/bracket/my_matches.dart';

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
    final t = AppLocalizations.of(context)!;
    return DefaultTabController(
      initialIndex: 1,
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          title: Text(
            t.bracketTitle,
            style: const TextStyle(
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
            isScrollable: true,
            labelColor: context.themeColors.accentColor,
            indicatorColor: context.themeColors.accentColor,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: t.bracketMyMatches),
              isBracket
                  ? Tab(text: t.bracketTitle)
                  : Tab(text: t.bracketScoreboard),
              Tab(text: t.bracketResults),
              Tab(text: t.bracketCalendar),
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
                            MyMatches(tournamentId: widget.tournamentID),
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
