import 'package:flutter/material.dart';
import 'package:front/main.dart';
import 'package:front/widget/bracket/bracket_match.dart';
import 'package:provider/provider.dart';

class Bracket extends StatelessWidget {
  Bracket({super.key});

  final List<List<Match>> tournament = [
    [
      Match(
        player1: 'Alcaraz C. (1)',
        player2: 'Medvedev D. (5)',
        playerOneId: 1,
        playerTwoId: 5,
        status: 'finished',
        score1: '2',
        score2: '0',
        winnerId: 1,
        time: '',
        tournament: 'US Open',
      ),
      Match(
        player1: 'Federer R. (3)',
        player2: 'Nadal R. (7)',
        playerOneId: 3,
        playerTwoId: 7,
        status: 'finished',
        score1: '2',
        score2: '1',
        winnerId: 3,
        time: '',
        tournament: 'US Open',
      ),
      Match(
        player1: 'Djokovic N. (9)',
        player2: 'Shapovalov D. (12)',
        playerOneId: 9,
        playerTwoId: 12,
        status: 'finished',
        score1: '2',
        score2: '0',
        winnerId: 9,
        time: '',
        tournament: 'US Open',
      ),
      Match(
        player1: 'Auger-Aliassime F. (14)',
        player2: 'Monfils G. (16)',
        playerOneId: 14,
        playerTwoId: 15,
        status: 'finished',
        score1: '1',
        score2: '2',
        winnerId: 15,
        time: '',
        tournament: 'US Open',
      ),
      Match(
        player1: 'Rublev A. (6)',
        player2: 'Sinner J. (2)',
        playerOneId: 13,
        playerTwoId: 21,
        status: 'finished',
        score1: '0',
        score2: '2',
        winnerId: 21,
        time: '',
        tournament: 'US Open',
      ),
      Match(
        player1: 'Ruud C. (4)',
        player2: '',
        playerOneId: 4,
        playerTwoId: null,
        status: 'not started',
        time: '',
        tournament: 'US Open',
      ),
      Match(
        player1: '',
        player2: '',
        playerOneId: null,
        playerTwoId: null,
        status: 'not started',
        time: '',
        tournament: 'US Open',
      ),
      Match(
        player1: '',
        player2: '',
        playerOneId: null,
        playerTwoId: null,
        status: 'not started',
        time: '',
        tournament: 'US Open',
      ),
    ],
    [
      Match(
        player1: 'Alcaraz C. (1)',
        player2: 'Federer R. (3)',
        playerOneId: 1,
        playerTwoId: 5,
        status: 'finished',
        score1: '1',
        score2: '2',
        winnerId: 5,
        time: '',
        tournament: 'US Open',
      ),
      Match(
        player1: 'Monfils G. (16)',
        player2: 'Djokovic N. (9)',
        playerOneId: 16,
        playerTwoId: 9,
        status: 'in progress',
        score1: '0',
        score2: '1',
        time: '',
        tournament: 'US Open',
      ),
      Match(
        player1: '',
        player2: 'Sinner J. (2)',
        playerOneId: null,
        playerTwoId: 21,
        status: 'not started',
        time: '',
        tournament: 'US Open',
      ),
      Match(
        player1: '',
        player2: '',
        playerOneId: null,
        playerTwoId: null,
        status: 'not started',
        score1: '',
        score2: '',
        time: '',
        tournament: 'US Open',
      ),
    ],
    [
      Match(
        player1: 'Djokovic N. (9)',
        player2: 'Federer R. (3)',
        playerOneId: 9,
        playerTwoId: 3,
        status: 'not started',
        score1: '',
        score2: '',
        winnerId: null,
        time: '18:00',
        tournament: 'US Open',
      ),
      Match(
        player1: '',
        player2: '',
        playerOneId: null,
        playerTwoId: null,
        status: 'not started',
        time: '',
        tournament: 'US Open',
      ),
    ],
    [
      Match(
        player1: '',
        player2: '',
        playerOneId: null,
        playerTwoId: null,
        status: 'not started',
        score1: '',
        score2: '',
        winnerId: null,
        time: '',
        tournament: 'US Open',
      ),
    ],
  ];

  final tabs = [
    const Tab(text: '1/64 DE FINALE'),
    const Tab(text: '1/32 DE FINALE'),
    const Tab(text: '1/16 DE FINALE'),
    const Tab(text: '1/8 DE FINALE'),
    const Tab(text: 'QUARTS DE FINALE'),
    const Tab(text: 'DEMI-FINALES'),
    const Tab(text: 'FINALE'),
  ];

  List<Widget> generateStep(List<Match> matches) {
    List<Widget> listViewBuilders = [];

    listViewBuilders.add(
      ListView.builder(
        itemCount: matches.length,
        itemBuilder: (context, index) {
          var match = matches[index];
          return Column(
            children: [
              SizedBox(height: index == 0 ? 16 : 0),
              BracketMatch(match: match),
              SizedBox(height: index.isOdd ? 16 : 5),
            ],
          );
        },
      ),
    );

    return listViewBuilders;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;

    return DefaultTabController(
      initialIndex: 0,
      length: tournament.length,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: TabBar(
            isScrollable: true,
            unselectedLabelColor: isDarkMode ? Colors.white : Colors.black,
            // Retrieve the last n tabs
            tabs: tabs.sublist(tabs.length - tournament.length, tabs.length),
          ),
        ),
        body: TabBarView(
          children: [
            for (var step in tournament) ...generateStep(step),
          ],
        ),
      ),
    );
  }
}

class Match {
  String? player1 = '';
  String? player2 = '';
  int? playerOneId;
  int? playerTwoId;
  final String status;
  String? score1 = '';
  String? score2 = '';
  int? winnerId;
  String? time = '';
  String? date = '';
  String? location = '';
  String? tournament = '';

  Match({
    this.player1,
    this.player2,
    this.playerOneId,
    this.playerTwoId,
    required this.status,
    this.score1,
    this.score2,
    this.winnerId,
    this.time,
    this.date,
    this.location,
    this.tournament,
  });
}
