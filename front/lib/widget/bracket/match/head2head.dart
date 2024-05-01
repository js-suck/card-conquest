import 'package:flutter/material.dart';
import 'package:front/widget/bracket/bracket.dart';
import 'package:front/widget/bracket/match/match_tiles.dart';

class Head2Head extends StatelessWidget {
  Head2Head({super.key});

  final List<Match> matchesPlayer1 = [
    Match(
      player1: 'Alcaraz',
      player2: 'Medvedev',
      playerOneId: 1,
      playerTwoId: 5,
      status: 'finished',
      score1: '2',
      score2: '0',
      winnerId: 1,
    ),
    Match(
      player1: 'Alcaraz',
      player2: 'Djokovic',
      playerOneId: 1,
      playerTwoId: 9,
      status: 'finished',
      score1: '2',
      score2: '0',
      winnerId: 1,
    ),
    Match(
      player1: 'Alcaraz',
      player2: 'Nadal',
      playerOneId: 1,
      playerTwoId: 7,
      status: 'finished',
      score1: '1',
      score2: '2',
      winnerId: 7,
    ),
    Match(
      player1: 'Alcaraz',
      player2: 'Federer',
      playerOneId: 1,
      playerTwoId: 3,
      status: 'finished',
      score1: '0',
      score2: '2',
      winnerId: 3,
    ),
    Match(
      player1: 'Alcaraz',
      player2: 'Thiem',
      playerOneId: 1,
      playerTwoId: 4,
      status: 'finished',
      score1: '2',
      score2: '0',
      winnerId: 1,
    ),
    Match(
      player1: 'Alcaraz',
      player2: 'Zverev',
      playerOneId: 1,
      playerTwoId: 8,
      status: 'finished',
      score1: '2',
      score2: '0',
      winnerId: 1,
    ),
    Match(
      player1: 'Alcaraz',
      player2: 'Rublev',
      playerOneId: 1,
      playerTwoId: 6,
      status: 'finished',
      score1: '2',
      score2: '0',
      winnerId: 1,
    ),
  ];

  final List<Match> matchesPlayer2 = [
    Match(
      player1: 'Medvedev',
      player2: 'Alcaraz',
      playerOneId: 5,
      playerTwoId: 1,
      status: 'finished',
      score1: '0',
      score2: '2',
      winnerId: 1,
    ),
    Match(
      player1: 'Medvedev',
      player2: 'Djokovic',
      playerOneId: 5,
      playerTwoId: 9,
      status: 'finished',
      score1: '2',
      score2: '1',
      winnerId: 5,
    ),
    Match(
      player1: 'Medvedev',
      player2: 'Nadal',
      playerOneId: 5,
      playerTwoId: 7,
      status: 'finished',
      score1: '0',
      score2: '2',
      winnerId: 7,
    ),
    Match(
      player1: 'Medvedev',
      player2: 'Federer',
      playerOneId: 5,
      playerTwoId: 3,
      status: 'finished',
      score1: '0',
      score2: '2',
      winnerId: 3,
    ),
    Match(
      player1: 'Medvedev',
      player2: 'Thiem',
      playerOneId: 5,
      playerTwoId: 4,
      status: 'finished',
      score1: '2',
      score2: '0',
      winnerId: 5,
    ),
    Match(
      player1: 'Medvedev',
      player2: 'Zverev',
      playerOneId: 5,
      playerTwoId: 6,
      status: 'finished',
      score1: '2',
      score2: '0',
      winnerId: 5,
    ),
    Match(
      player1: 'Medvedev',
      player2: 'Rublev',
      playerOneId: 5,
      playerTwoId: 8,
      status: 'finished',
      score1: '2',
      score2: '0',
      winnerId: 5,
    ),
  ];

  final List<Match> matchesH2H = [
    Match(
      player1: 'Medvedev',
      player2: 'Alcaraz',
      playerOneId: 5,
      playerTwoId: 1,
      status: 'finished',
      score1: '0',
      score2: '2',
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
