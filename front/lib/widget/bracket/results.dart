import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:front/models/match/match.dart';
import 'package:front/service/match_service.dart';
import 'package:front/widget/bracket/match/match_tiles.dart';

import '../../utils/custom_future_builder.dart';

class Results extends StatefulWidget {
  const Results({super.key, required this.tournamentId});

  final int tournamentId;

  @override
  State<Results> createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  late MatchService matchService;
  late Future<List<Match>> matchesFuture;

  @override
  void initState() {
    super.initState();
    matchService = MatchService();
    matchesFuture = fetchMatches();
  }

  Future<List<Match>> fetchMatches() {
    return matchService.fetchFinishedMatchesOfTournament(_tournamentId);
  }

  Future<void> _refreshMatches() async {
    setState(() {
      matchesFuture = fetchMatches();
    });
  }

  get _tournamentId => widget.tournamentId;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshMatches,
      child: CustomFutureBuilder(
        future: matchesFuture,
        onLoaded: (matches) {
          final groupedMatches =
              groupBy(matches, (match) => match.tournamentStep.sequence);
          final sortedMatches = groupedMatches.keys.toList()
            ..sort((a, b) => b.compareTo(a));
          List<Widget> tournamentStepWidgets = [];
          for (var step in sortedMatches) {
            tournamentStepWidgets.add(
              MatchTiles(
                matches: groupedMatches[step]!,
                isSteps: true,
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: tournamentStepWidgets,
            ),
          );
        },
      ),
    );
  }
}
