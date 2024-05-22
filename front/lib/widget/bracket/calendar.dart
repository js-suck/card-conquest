import 'package:flutter/material.dart';
import 'package:front/widget/bracket/bracket.dart';
import 'package:front/widget/bracket/match/match_tiles.dart';

class Calendar extends StatelessWidget {
  Calendar({super.key});

  final List<Match> matches = [
    Match(
        player1: 'Alcaraz C',
        player2: 'Medvedev D',
        playerOneId: 1,
        playerTwoId: 5,
        status: 'not started',
        time: '14:00',
        date: '07.05.'),
    Match(
        player1: 'Federer R',
        player2: 'Nadal R',
        playerOneId: 3,
        playerTwoId: 7,
        status: 'not started',
        time: '15:00',
        date: '07.05.'),
    Match(
        player1: 'Djokovic N',
        player2: 'Shapovalov D',
        playerOneId: 9,
        playerTwoId: 12,
        status: 'not started',
        time: '16:00',
        date: '07.05.'),
    Match(
        player1: 'Auger-Aliassime F',
        player2: 'Monfils G',
        playerOneId: 14,
        playerTwoId: 15,
        status: 'not started',
        time: '17:00',
        date: '08.05.'),
    Match(
        player1: 'Rublev A',
        player2: 'Sinner J',
        playerOneId: 13,
        playerTwoId: 21,
        status: 'not started',
        time: '18:00',
        date: '08.05.'),
    Match(
      player1: 'Tsitsipas S',
      player2: 'Zverev A',
      playerOneId: 11,
      playerTwoId: 10,
      status: 'not started',
      time: '19:00',
      date: '08.05.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MatchTiles(matches: matches, isPast: false);
  }
}
