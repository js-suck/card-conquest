import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/generated/tournament.pb.dart' as tournament;
import 'package:front/widget/app_bar.dart';
import 'package:front/widget/bracket/match/match_tiles.dart';

class PlayerPage extends StatelessWidget {
  PlayerPage({super.key});

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
        username: 'Zverev',
        userId: '8',
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
        username: 'Rublev',
        userId: '6',
        score: 0,
      ),
      status: 'finished',
      winnerId: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final tournament.Player player = args['player'] as tournament.Player;
    final bool isTournament = args['isTournament'] as bool;

    return Scaffold(
      appBar: TopAppBar(
        title: player.username,
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
                        player.username,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Age: player.age',
                        style: TextStyle(
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
                  const Text('Classement: player.classement.toString()'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (!isTournament)
              for (var tournament in groupBy(matchesPlayer1,
                  (tournament.Match match) => 'match.tournament').entries)
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
