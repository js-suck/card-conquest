import 'package:flutter/material.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/generated/tournament.pb.dart' as tournament;
import 'package:front/widget/bracket/match/match_tile.dart';

class MatchTiles extends StatefulWidget {
  const MatchTiles({
    super.key,
    required this.matches,
    this.isPast = true,
    this.isLastMatches = false,
    this.isH2H = false,
    this.isScoreboard = false,
  });

  final List<tournament.Match> matches;
  final bool isPast;
  final bool isLastMatches;
  final bool isH2H;
  final bool isScoreboard;

  @override
  State<MatchTiles> createState() => _MatchTilesState();
}

class _MatchTilesState extends State<MatchTiles> {
  bool showMoreMatches = false;

  List<tournament.Match> get displayMatches => !showMoreMatches &&
          (widget.isLastMatches || widget.isH2H || widget.isScoreboard)
      ? widget.matches.take(5).toList()
      : widget.matches;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < displayMatches.length; index++) ...[
          if (index == 0 &&
              (widget.isLastMatches || widget.isH2H || widget.isScoreboard))
            Builder(builder: (context) {
              if (widget.isH2H) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  color: context.themeColors.backgroundColor,
                  width: double.infinity,
                  child: const Text(
                    'Confrontations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              } else if (widget.isScoreboard) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  color: context.themeColors.backgroundColor,
                  width: double.infinity,
                  child: const Text(
                    'Tournoi: nomDuTournoi',
                    style: TextStyle(
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
                    'Derniers matchs: ${displayMatches[index].playerOne.username}',
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
                    Text(showMoreMatches ? 'Afficher moins' : 'Afficher plus'),
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
