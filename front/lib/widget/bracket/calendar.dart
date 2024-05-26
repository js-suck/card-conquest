import 'package:flutter/material.dart';
import 'package:front/generated/tournament.pb.dart' as tournament;
import 'package:front/widget/bracket/match/match_tiles.dart';

class Calendar extends StatelessWidget {
  Calendar({super.key});

  final List<tournament.Match> matches = [
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Alcaraz C',
        userId: '1',
        score: 0,
      ),
      playerTwo: tournament.Player(
        username: 'Medvedev D',
        userId: '5',
        score: 0,
      ),
      status: 'Created',
    ),
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Federer R',
        userId: '3',
        score: 0,
      ),
      playerTwo: tournament.Player(
        username: 'Nadal R',
        userId: '7',
        score: 0,
      ),
      status: 'Created',
    ),
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Djokovic N',
        userId: '9',
        score: 0,
      ),
      playerTwo: tournament.Player(
        username: 'Shapovalov D',
        userId: '12',
        score: 0,
      ),
      status: 'Created',
    ),
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Auger-Aliassime F',
        userId: '14',
        score: 0,
      ),
      playerTwo: tournament.Player(
        username: 'Monfils G',
        userId: '16',
        score: 0,
      ),
      status: 'Created',
    ),
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Tsitsipas S',
        userId: '11',
        score: 0,
      ),
      playerTwo: tournament.Player(
        username: 'Zverev A',
        userId: '10',
        score: 0,
      ),
      status: 'Created',
    ),
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Rublev A',
        userId: '6',
        score: 0,
      ),
      playerTwo: tournament.Player(
        username: 'Sinner J',
        userId: '2',
        score: 0,
      ),
      status: 'Created',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MatchTiles(matches: matches, isPast: false);
  }
}
