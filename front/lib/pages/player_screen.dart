import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/widget/app_bar.dart';
import 'package:front/widget/bracket/bracket.dart';
import 'package:front/widget/bracket/match/match_tiles.dart';
import 'package:front/widget/bracket/scoreboard.dart';

class PlayerPage extends StatelessWidget {
  PlayerPage({super.key});

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
      tournament: 'US Open',
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
      tournament: 'US Open',
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
      tournament: 'Roland Garros',
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
      tournament: 'Roland Garros',
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
      tournament: 'Wimbledon',
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
      tournament: 'Wimbledon',
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
      tournament: 'Wimbledon',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    final Player player = args!['player'] as Player;
    final bool isTournament = args['isTournament'] as bool;

    return Scaffold(
      appBar: TopAppBar(
        title: player.nom,
        isPage: true,
        isAvatar: false,
        isSettings: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 100,
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                        left: 20, right: 10, top: 10, bottom: 10),
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/avatar.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.nom,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Age: ${player.age.toString()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 20, right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: context.themeColors.invertedBackgroundColor,
                    ),
                    width: 40,
                    height: 40,
                    child: Center(
                      child: Icon(
                        Icons.leaderboard,
                        color: context.themeColors.backgroundColor,
                      ),
                    ),
                  ),
                  Text('Classement: ${player.classement.toString()}'),
                ],
              ),
            ),
            if (!isTournament)
              for (var tournament
                  in groupBy(matchesPlayer1, (Match match) => match.tournament)
                      .entries)
                MatchTiles(
                  matches: tournament.value,
                  isScoreboard: true,
                ),
            if (isTournament) MatchTiles(matches: matchesPlayer1)
          ],
        ),
      ),
    );
  }
}
