import 'package:flutter/material.dart';

class Scoreboard extends StatelessWidget {
  Scoreboard({super.key, this.isTounament = true});

  final bool isTounament;

  final List<Player> players = [
    Player(
      nom: 'Roger Federer',
      matchsJoues: 20,
      victoires: 15,
      defaites: 5,
      points: 1500,
      age: 40,
      classement: 1,
    ),
    Player(
      nom: 'Rafael Nadal',
      matchsJoues: 22,
      victoires: 18,
      defaites: 4,
      points: 1600,
      age: 35,
      classement: 2,
    ),
    Player(
      nom: 'Novak Djokovic',
      matchsJoues: 24,
      victoires: 20,
      defaites: 4,
      points: 1700,
      age: 33,
      classement: 3,
    ),
    Player(
      nom: 'Carlos Alcaraz',
      matchsJoues: 18,
      victoires: 14,
      defaites: 4,
      points: 1400,
      age: 18,
      classement: 4,
    )
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
                'isTournament': isTounament,
              });
            },
            leading: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: CircleAvatar(
                    child: Image.asset('assets/images/avatar.png'))),
            title: Text('${player.nom} (${player.classement})'),
            subtitle: Text('Matchs joués: ${player.matchsJoues}'),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Victoires: ${player.victoires}'),
                Text('Défaites: ${player.defaites}'),
                Text('Points: ${player.points}'),
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
