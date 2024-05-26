import 'package:flutter/material.dart';
import 'package:front/generated/tournament.pb.dart' as tournament;
import 'package:front/widget/bracket/match/match_tiles.dart';

class Results extends StatelessWidget {
  Results({super.key});

  final List<tournament.Match> matches = [
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Alcaraz C',
        userId: '1',
        score: 2,
      ),
      playerTwo: tournament.Player(
        username: 'Medvedev D',
        userId: '5',
        score: 0,
      ),
      status: 'finished',
      winnerId: 1,
    ),
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Federer R',
        userId: '3',
        score: 2,
      ),
      playerTwo: tournament.Player(
        username: 'Nadal R',
        userId: '7',
        score: 1,
      ),
      status: 'finished',
      winnerId: 3,
    ),
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Djokovic N',
        userId: '9',
        score: 2,
      ),
      playerTwo: tournament.Player(
        username: 'Shapovalov D',
        userId: '12',
        score: 0,
      ),
      status: 'finished',
      winnerId: 9,
    ),
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Auger-Aliassime F',
        userId: '14',
        score: 2,
      ),
      playerTwo: tournament.Player(
        username: 'Monfils G',
        userId: '16',
        score: 0,
      ),
      status: 'finished',
      winnerId: 14,
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
        score: 2,
      ),
      status: 'finished',
      winnerId: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MatchTiles(
      matches: matches,
    );
  }
}
