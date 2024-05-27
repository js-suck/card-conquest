import 'package:flutter/material.dart';
import 'package:front/generated/tournament.pb.dart' as tournament;
import 'package:front/generated/tournament.pb.dart';
import 'package:front/main.dart';
import 'package:front/widget/app_bar.dart';
import 'package:front/widget/bracket/match/head2head.dart';
import 'package:front/widget/bracket/match/summary.dart';
import 'package:front/widget/bracket/scoreboard.dart' as scoreboard;
import 'package:provider/provider.dart';

import '../widget/bracket/bracket.dart';
import '../widget/bracket/scoreboard.dart';

class MatchPage extends StatelessWidget {
  MatchPage({super.key});

  final bool isBracket = true;

  final scoreboard.Player player1 = scoreboard.Player(
    nom: 'Alcaraz C.',
    age: 18,
    matchsJoues: 5,
    victoires: 5,
    defaites: 0,
    points: 1500,
    classement: 1,
  );

  final scoreboard.Player player2 = scoreboard.Player(
    nom: 'Medvedev D.',
    age: 25,
    matchsJoues: 5,
    victoires: 4,
    defaites: 1,
    points: 1400,
    classement: 2,
  );

  final status = {
    'created': 'Créé',
    'started': 'En cours',
    'finished': 'Terminé',
  };

  @override
  Widget build(BuildContext context) {
    final tournament.Match match =
        ModalRoute.of(context)!.settings.arguments as tournament.Match;
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final fontColor = isDarkMode ? Colors.white : Colors.black;

    return StreamBuilder<TournamentResponse>(
        stream: null,
        builder: (context, snapshot) {
          return Provider(
            create: (Match) => match,
            child: Scaffold(
              appBar: const TopAppBar(
                title: 'Match',
                isPage: true,
                isAvatar: false,
                isSettings: false,
              ),
              body: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 16.0, left: 12.0, right: 8.0, bottom: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/player',
                                  arguments: {
                                    'player': match.playerOne,
                                    'isTournament': true
                                  });
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 65,
                                  height: 65,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(10),
                                    image: const DecorationImage(
                                      image: AssetImage(
                                          'assets/images/avatar.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Text(
                                  match.playerOne.username,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: match.winnerId.toString() ==
                                            match.playerOne.userId
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                const Text('Cla. 1.',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          children: [
                            const Text(
                              'match.date match.time',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${match.playerOne.score} - ${match.playerTwo.score}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: match.status == 'started'
                                    ? Colors.red
                                    : fontColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(status[match.status]!,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: match.status == 'started'
                                        ? Colors.redAccent
                                        : Colors.grey)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 16.0, left: 8.0, right: 12.0, bottom: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/player',
                                  arguments: {
                                    'player': match.playerTwo,
                                    'isTournament': true
                                  });
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 65,
                                  height: 65,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(10),
                                    image: const DecorationImage(
                                      image: AssetImage(
                                          'assets/images/avatar.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Text(
                                  match.playerTwo.username,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: match.winnerId.toString() ==
                                            match.playerTwo.userId
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                const Text('Cla. 2.',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                      child: DefaultTabController(
                    length: 5,
                    child: Column(
                      children: [
                        Container(
                          height: 50,
                          color: isDarkMode
                              ? Colors.black
                              : const Color(0xff1a4ccb),
                          child: const TabBar(
                            // isScrollable: true,
                            tabs: [
                              Tab(text: 'Résumé'),
                              // Tab(text: 'Stats'),
                              // Tab(text: 'Point par point'),
                              Tab(text: 'TÀT'),
                              Tab(text: 'Tableau'),
                            ],
                          ),
                        ),
                        Flexible(
                          child: TabBarView(
                            children: [
                              Summary(match: match),
                              // const Center(child: Text('Stats')),
                              // const Center(child: Text('Point par point')),
                              Head2Head(),
                              isBracket ? Bracket(snapshot) : Scoreboard(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          );
        });
  }
}
