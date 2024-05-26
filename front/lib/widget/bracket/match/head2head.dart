import 'package:flutter/material.dart';
import 'package:front/generated/tournament.pb.dart' as tournament;

import 'match_tiles.dart';

class Head2Head extends StatelessWidget {
  Head2Head({super.key});

  final List<tournament.Match> matchesPlayer1 = [
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Alcaraz',
        userId: '1',
        score: 2,
      ),
      playerTwo: tournament.Player(
        username: 'Medvedev',
        userId: '5',
        score: 0,
      ),
      status: 'finished',
      winnerId: 1,
    ),
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Alcaraz',
        userId: '1',
        score: 0,
      ),
      playerTwo: tournament.Player(
        username: 'Djokovic',
        userId: '9',
        score: 2,
      ),
      status: 'finished',
      winnerId: 9,
    ),
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Alcaraz',
        userId: '1',
        score: 0,
      ),
      playerTwo: tournament.Player(
        username: 'Nadal',
        userId: '7',
        score: 2,
      ),
      status: 'finished',
      winnerId: 7,
    ),
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Alcaraz',
        userId: '1',
        score: 0,
      ),
      playerTwo: tournament.Player(
        username: 'Federer',
        userId: '3',
        score: 2,
      ),
      status: 'finished',
      winnerId: 3,
    ),
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Alcaraz',
        userId: '1',
        score: 2,
      ),
      playerTwo: tournament.Player(
        username: 'Thiem',
        userId: '4',
        score: 0,
      ),
      status: 'finished',
      winnerId: 1,
    ),
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Alcaraz',
        userId: '1',
        score: 2,
      ),
      playerTwo: tournament.Player(
        username: 'Zverev',
        userId: '6',
        score: 0,
      ),
      status: 'finished',
      winnerId: 1,
    ),
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Alcaraz',
        userId: '1',
        score: 2,
      ),
      playerTwo: tournament.Player(
        username: 'Rublev',
        userId: '8',
        score: 0,
      ),
      status: 'finished',
      winnerId: 1,
    ),
  ];

  final List<tournament.Match> matchesPlayer2 = [
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Medvedev',
        userId: '5',
        score: 0,
      ),
      playerTwo: tournament.Player(
        username: 'Alcaraz',
        userId: '1',
        score: 2,
      ),
      status: 'finished',
      winnerId: 1,
    ),
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Medvedev',
        userId: '5',
        score: 2,
      ),
      playerTwo: tournament.Player(
        username: 'Djokovic',
        userId: '9',
        score: 0,
      ),
      status: 'finished',
      winnerId: 5,
    ),
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Medvedev',
        userId: '5',
        score: 2,
      ),
      playerTwo: tournament.Player(
        username: 'Nadal',
        userId: '7',
        score: 0,
      ),
      status: 'finished',
      winnerId: 5,
    ),
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Medvedev',
        userId: '5',
        score: 2,
      ),
      playerTwo: tournament.Player(
        username: 'Federer',
        userId: '3',
        score: 0,
      ),
      status: 'finished',
      winnerId: 5,
    ),
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Medvedev',
        userId: '5',
        score: 2,
      ),
      playerTwo: tournament.Player(
        username: 'Thiem',
        userId: '4',
        score: 0,
      ),
      status: 'finished',
      winnerId: 5,
    ),
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Medvedev',
        userId: '5',
        score: 2,
      ),
      playerTwo: tournament.Player(
        username: 'Zverev',
        userId: '6',
        score: 0,
      ),
      status: 'finished',
      winnerId: 5,
    ),
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Medvedev',
        userId: '5',
        score: 2,
      ),
      playerTwo: tournament.Player(
        username: 'Rublev',
        userId: '8',
        score: 0,
      ),
      status: 'finished',
      winnerId: 5,
    ),
  ];

  final List<tournament.Match> matchesH2H = [
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Alcaraz',
        userId: '1',
        score: 2,
      ),
      playerTwo: tournament.Player(
        username: 'Medvedev',
        userId: '5',
        score: 0,
      ),
      status: 'finished',
      winnerId: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          MatchTiles(
            key: UniqueKey(),
            matches: matchesPlayer1,
            isLastMatches: true,
          ),
          MatchTiles(
            key: UniqueKey(),
            matches: matchesPlayer2,
            isLastMatches: true,
          ),
          MatchTiles(
            key: UniqueKey(),
            matches: matchesH2H,
            isLastMatches: false,
            isH2H: true,
          ),
        ],
      ),
    );
  }
}
