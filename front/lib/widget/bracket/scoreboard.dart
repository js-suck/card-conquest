import 'package:flutter/material.dart';
import 'package:front/generated/tournament.pb.dart' as tournament;

class Scoreboard extends StatelessWidget {
  Scoreboard({super.key, this.isTournament = true});

  final bool isTournament;

  final List<tournament.Player> players = [
    tournament.Player(
      username: 'Federer R',
      userId: '3',
    ),
    tournament.Player(
      username: 'Nadal R',
      userId: '7',
    ),
    tournament.Player(
      username: 'Djokovic N',
      userId: '9',
    ),
    tournament.Player(
      username: 'Shapovalov D',
      userId: '12',
    ),
    // Ajoute d'autres joueurs ou équipes au besoin
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        separatorBuilder: (context, index) => const Divider(
          height: 0,
        ),
        itemCount: players.length,
        itemBuilder: (context, index) {
          final player = players[index];
          return ListTile(
            onTap: () {
              // Naviguer vers la page du joueur
              Navigator.pushNamed(context, '/player', arguments: {
                'player': player,
                'isTournament': isTournament,
              });
            },
            leading: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: CircleAvatar(
                    child: Image.asset('assets/images/avatar.png'))),
            title: Text('${player.username} (player.classement)'),
            subtitle: const Text('Matchs joués: player.matchsJoues'),
            trailing: const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Victoires: player.victoires'),
                Text('Défaites: player.defaites'),
                Text('Points: player.points'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Player {
  final String nom;
  final int matchsJoues;
  final int victoires;
  final int defaites;
  final int points;
  final int age;
  final int classement;

  Player({
    required this.nom,
    required this.matchsJoues,
    required this.victoires,
    required this.defaites,
    required this.points,
    required this.age,
    required this.classement,
  });
}
