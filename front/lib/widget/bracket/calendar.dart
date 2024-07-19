import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:front/models/match/match.dart';
import 'package:front/service/match_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:front/utils/custom_future_builder.dart';
import 'package:front/widget/bracket/match/match_tiles.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key, required this.tournamentId});

  final int tournamentId;

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late MatchService matchService;
  late Future<List<Match>> matchesFuture;

  @override
  void initState() {
    super.initState();
    matchService = MatchService();
    matchesFuture = fetchMatches();
  }

  Future<List<Match>> fetchMatches() {
    return matchService.fetchUnfinishedMatchesOfTournament(_tournamentId);
  }

  Future<void> _refreshMatches() async {
    setState(() {
      matchesFuture = fetchMatches();
    });
  }

  get _tournamentId => widget.tournamentId;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return RefreshIndicator(
      onRefresh: _refreshMatches,
      child: CustomFutureBuilder(
          future: matchesFuture,
          onLoaded: (matches) {
            if (matches.isEmpty) {
              return Center(
                child: Text(t.playerNoMatches),
              );
            }
            final groupedMatches =
                groupBy(matches, (match) => match.tournamentStep.sequence);
            List<Widget> tournamentStepWidgets = [];
            groupedMatches.forEach((sequence, matches) {
              tournamentStepWidgets.add(
                MatchTiles(
                  matches: matches,
                  isSteps: true,
                ),
              );
            });

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: tournamentStepWidgets,
              ),
            );
          }),
    );
    /* TODO: Add matches for the calendar
    return MatchTiles(matches: matches, isPast: false);

     */
  }
}
