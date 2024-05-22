import 'package:flutter/material.dart';
import 'package:front/widget/bracket/bracket.dart';
import 'package:front/widget/bracket/match/match_tiles.dart';

class Results extends StatelessWidget {
  Results({super.key});

  final List<Match> matches = [
    Match(
      player1: 'Alcaraz C',
      player2: 'Medvedev D',
      playerOneId: 1,
      playerTwoId: 5,
      status: 'finished',
      score1: '2',
      score2: '0',
      winnerId: 1,
    ),
    Match(
      player1: 'Federer R',
      player2: 'Nadal R',
      playerOneId: 3,
      playerTwoId: 7,
      status: 'finished',
      score1: '2',
      score2: '1',
      winnerId: 3,
    ),
    Match(
      player1: 'Djokovic N',
      player2: 'Shapovalov D',
      playerOneId: 9,
      playerTwoId: 12,
      status: 'finished',
      score1: '2',
      score2: '0',
      winnerId: 9,
    ),
    Match(
      player1: 'Auger-Aliassime F',
      player2: 'Monfils G',
      playerOneId: 14,
      playerTwoId: 15,
      status: 'finished',
      score1: '1',
      score2: '2',
      winnerId: 15,
    ),
    Match(
      player1: 'Rublev A',
      player2: 'Sinner J',
      playerOneId: 13,
      playerTwoId: 21,
      status: 'finished',
      score1: '0',
      score2: '2',
      winnerId: 21,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MatchTiles(
      matches: matches,
    );
  }
}
