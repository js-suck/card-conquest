import 'dart:math';

import 'package:flutter/material.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/generated/tournament.pb.dart' as tournament_grpc;
import 'package:front/pages/bracket_screen.dart';
import 'package:front/widget/bracket/bracket_match.dart';
import 'package:provider/provider.dart';

import '../../generated/tournament.pb.dart';

class Bracket extends StatefulWidget {
  final tournament_grpc.TournamentResponse tournamentStream;

  const Bracket(this.tournamentStream, {super.key});

  @override
  State<Bracket> createState() => _BracketState();
}

class _BracketState extends State<Bracket> {
  final tabs = [
    const Tab(text: '1/64 DE FINALE'),
    const Tab(text: '1/32 DE FINALE'),
    const Tab(text: '1/16 DE FINALE'),
    const Tab(text: '1/8 DE FINALE'),
    const Tab(text: 'QUARTS DE FINALE'),
    const Tab(text: 'DEMI-FINALES'),
    const Tab(text: 'FINALE'),
  ];

  List<Widget> generateStep(TournamentStep step, tournamentSize) {
    List<Widget> listViewBuilders = [];
    final tournamentData = widget.tournamentStream;
    int matchesInThisRound = (1 << (tournamentSize - 1));

    final tournamentSteps = tournamentData.tournamentSteps.length;
    while (tournamentData.tournamentSteps.length < tournamentSize) {
      tournamentData.tournamentSteps.add(TournamentStep());
    }

    for (var step in tournamentData.tournamentSteps) {
      step.matches.sort((a, b) => a.position.compareTo(b.position));
    }

    for (var step in tournamentData.tournamentSteps) {
      while (step.matches.length < matchesInThisRound) {
        step.matches.add(Match(position: 999));
      }
      matchesInThisRound = (matchesInThisRound / 2).ceil();
    }

    // retrieve all matches from all steps
    /*
    final List<tournament_grpc.Match> matchesStream = [];
    for (var tournamentStep in tournamentData.tournamentSteps) {
      matchesStream.add(tournamentStep.matches as tournament_grpc.Match);
    }
     */
    listViewBuilders.add(
      ListView.builder(
        itemCount: step.matches.length,
        itemBuilder: (context, index) {
          var match = step.matches[index];
          return Column(
            children: [
              SizedBox(height: index == 0 ? 16 : 0),
              BracketMatch(match: match),
              SizedBox(height: index.isOdd ? 16 : 5),
            ],
          );
        },
      ),
    );

    return listViewBuilders;
  }

  @override
  Widget build(BuildContext context) {
    final tournamentData = widget.tournamentStream;
    final tournamentSteps = tournamentData.tournamentSteps;
    final tournament = context.watch<TournamentNotifier>().tournament;
    var players = tournament?.playersRegistered;
    var tournamentSize = (log(players as int) / log(2)).ceil();
    // generate empty matches
    for (int i = 0; i < tournamentSize; i++) {
      tournament_grpc.Player player = tournament_grpc.Player();
    }
    return DefaultTabController(
      initialIndex: 0,
      length: 4,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: TabBar(
            isScrollable: true,
            unselectedLabelColor: context.themeColors.fontColor,
            indicatorColor: context.themeColors.accentColor,
            // Retrieve the last n tabs
            tabs: tabs.sublist(tabs.length - tournamentSize, tabs.length),
          ),
        ),
        body: TabBarView(
          children: [
            for (int step = 0; step < tournamentSize; step++)
              ...generateStep(tournamentSteps[step], tournamentSize),
          ],
        ),
      ),
    );
  }
}
