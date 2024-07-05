import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/models/match/match.dart';
import 'package:front/pages/bracket_screen.dart';
import 'package:front/widget/bracket/match/match_tile.dart';
import 'package:provider/provider.dart';

class MatchTiles extends StatefulWidget {
  const MatchTiles(
      {super.key,
      required this.matches,
      this.isPast = true,
      this.isLastMatches = false,
      this.isH2H = false,
      this.isScoreboard = false,
      this.isSecond = false,
      this.isSteps = false,
      this.player,
      this.matchId});

  final List<Match> matches;
  final bool isPast;
  final bool isLastMatches;
  final bool isH2H;
  final bool isScoreboard;
  final bool isSecond;
  final bool isSteps;
  final player;
  final matchId;

  List<Match> get sortedMatches =>
      matches..sort((a, b) => a.startTime.compareTo(b.startTime));

  @override
  State<MatchTiles> createState() => _MatchTilesState();
}

class _MatchTilesState extends State<MatchTiles> {
  bool showMoreMatches = false;

  List<Match> get displayMatches => !showMoreMatches &&
          (widget.isLastMatches || widget.isH2H || widget.isScoreboard)
      ? widget.sortedMatches.take(5).toList()
      : widget.sortedMatches;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final tabs = [
      Tab(text: t.bracketRoundOf64),
      Tab(text: t.bracketRoundOf32),
      Tab(text: t.bracketRoundOf16),
      Tab(text: t.bracketRoundOf8),
      Tab(text: t.bracketRoundOf4),
      Tab(text: t.bracketRoundOf2),
      Tab(text: t.bracketRoundOf1),
    ];
    final tournament = context.watch<TournamentNotifier>().tournament;
    final players = tournament?.playersRegistered;
    final tournamentSize = players != null ? (log(players) / log(2)).ceil() : 0;
    final newTabs = tabs.sublist(tabs.length - tournamentSize);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < displayMatches.length; index++) ...[
          if (index == 0 &&
              (widget.isLastMatches ||
                  widget.isH2H ||
                  widget.isScoreboard ||
                  widget.isSteps))
            Builder(builder: (context) {
              if (widget.isH2H) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  color: context.themeColors.backgroundColor,
                  width: double.infinity,
                  child: Text(
                    t.matchConfrontation,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              } else if (widget.isScoreboard) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/tournament',
                        arguments: displayMatches[index].tournament.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: context.themeColors.backgroundColor,
                    width: double.infinity,
                    child: Text(
                      '${t.matchTournament}: ${displayMatches[index].tournament.name}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              } else if (widget.isSteps) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  color: context.themeColors.backgroundColor,
                  width: double.infinity,
                  child: Text(
                    '${t.matchTournamentStep}: ${newTabs[displayMatches[index].tournamentStep.sequence - 1].text}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              } else {
                return Container(
                  padding: const EdgeInsets.all(8),
                  color: context.themeColors.backgroundColor,
                  width: double.infinity,
                  child: Text(
                    '${t.matchLastMatches}: ${widget.player.username}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
            }),
          MatchTile(
            match: displayMatches[index],
            isPast: widget.isPast,
            isLastMatches: widget.isLastMatches,
            isSecond: widget.isSecond,
            matchId: widget.matchId,
            playerId: widget.player != null ? widget.player.id : 0,
          ),
          const Divider(
            height: 1,
          ),

          if (displayMatches.length - 1 == index &&
              widget.matches.length > 5 &&
              (widget.isH2H || widget.isLastMatches || widget.isScoreboard))
            GestureDetector(
              onTap: () {
                setState(() {
                  showMoreMatches = !showMoreMatches;
                });
              },
              child: Container(
                height: 50,
                color: context.themeColors.secondaryBackgroundAccentColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(showMoreMatches ? t.matchShowLess : t.matchShowMore),
                    Icon(showMoreMatches
                        ? Icons.keyboard_arrow_up_sharp
                        : Icons.keyboard_arrow_down_sharp)
                  ],
                ),
              ),
            ),
          //SizedBox(height: widget.matches.length - 1 == index ? 50 : 0),
        ],
      ],
    );
  }
}
