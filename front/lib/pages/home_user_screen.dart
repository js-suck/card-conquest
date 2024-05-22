import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:front/widget/app_bar.dart';
import 'package:front/pages/games_screen.dart';
import 'package:front/pages/tournaments_screen.dart';


class Tournament {
  // id, title, date, time, imageUrl, status, tags
  final String title;
  final String date;
  final String time;
  final String imageUrl;
  final String status;
  final List<String> tags;

  Tournament({
    required this.title,
    required this.date,
    required this.time,
    required this.imageUrl,
    required this.status,
    required this.tags,
  });
}

class Game {
  final String title;
  final String category;
  final String imageUrl;

  Game({
    required this.title,
    required this.category,
    required this.imageUrl,
  });
}


class HomeUserPage extends StatefulWidget {
  const HomeUserPage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomeUserPage> {
  List<Tournament> recentTournaments = [];
  List<Tournament> allTournaments = [];
  List<Game> games = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // Utilisez des données d'exemple pour l'instant
    setState(() {
      recentTournaments = [
        Tournament(
          title: 'Heartstone cup #2',
          date: '05.05.23',
          time: '19:00',
          imageUrl: 'assets/images/img.png',
          status: 'create',
          tags: ['1v1', 'Casual'],
        ),
        Tournament(
          title: 'Tournoi des douze',
          date: '05.05.23',
          time: '15:00',
          imageUrl: 'assets/images/img.png',
          status: 'create',
          tags: ['3v3', 'Cashprice'],
        ),
        Tournament(
          title: 'Heartstone cup #2',
          date: '05.05.23',
          time: '19:00',
          imageUrl: 'assets/images/img.png',
          status: 'create',
          tags: ['1v1', 'Casual'],
        ),
        Tournament(
          title: 'Tournoi des douze',
          date: '05.05.23',
          time: '15:00',
          imageUrl: 'assets/images/img.png',
          status: 'create',
          tags: ['3v3', 'Cashprice'],
        ),
        // Ajoutez d'autres tournois récents ici
      ];

      allTournaments = [
        Tournament(
          title: 'Tournoi des douze',
          date: '05.05.23',
          time: '15:00',
          imageUrl: 'assets/images/img.png',
          status: 'create',
          tags: ['3v3', 'Cashprice'],
        ),
        Tournament(
          title: 'Heartstone cup #2',
          date: '05.05.23',
          time: '19:00',
          imageUrl: 'assets/images/img.png',
          status: 'create',
          tags: ['1v1', 'Casual'],
        ),
        Tournament(
          title: 'Tournoi des douze',
          date: '05.05.23',
          time: '15:00',
          imageUrl: 'assets/images/img.png',
          status: 'create',
          tags: ['3v3', 'Cashprice'],
        ),
        Tournament(
          title: 'Heartstone cup #2',
          date: '05.05.23',
          time: '19:00',
          imageUrl: 'assets/images/img.png',
          status: 'create',
          tags: ['1v1', 'Casual'],
        ),
        // Ajoutez d'autres tournois ici
      ];

      games = [
        Game(
          title: 'Waven',
          category: 'Aventure - MMORPG',
          imageUrl: 'assets/images/img.png',
        ),
        Game(
          title: 'Hearthstone',
          category: 'Cartes - Stratégie',
          imageUrl: 'assets/images/img.png',
        ),
        Game(
          title: 'League of Legends',
          category: 'MOBA',
          imageUrl: 'assets/images/img.png',
        ),
        Game(
          title: 'Valorant',
          category: 'FPS',
          imageUrl: 'assets/images/img.png',
        ),
        // Ajoutez d'autres jeux ici
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(title: 'Accueil', isAvatar: true, isPage: false),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSectionTitle('Tournois récent'),
            _buildHorizontalList(recentTournaments),
            _buildSectionTitleWithButton('Les tournois', 'Voir les tournois', () {
              // Naviguez vers la page des tournois avec la bottom navigation bar
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TournamentsPage()),
              );

            }),
            _buildVerticalList(allTournaments),
            _buildSectionTitleWithButton('Les jeux', 'Tous les jeux', () {
              // Naviguez vers la page des jeux
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GamesPage()),
              );
            }),
            _buildHorizontalListGames(games),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSectionTitleWithButton(String title, String buttonText, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: onPressed,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(List<dynamic> items) {
    return Container(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          var item = items[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(item.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${item.date} - ${item.time}",
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalListGames(List<dynamic> items) {
    return Container(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          var item = items[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(item.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${item.category}",
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerticalList(List<Tournament> items) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.67,
          ),
          itemBuilder: (context, index) {
          var item = items[index];
    return Container(
    width: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              image: DecorationImage(
                image: AssetImage(item.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  "${item.date} - ${item.time}",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 2),
                Wrap(
                  spacing: 2,
                  children: item.tags.map((tag) => Chip(
                    // no line on border
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: BorderSide(color: Colors.transparent),
                    ),
                    padding: EdgeInsets.zero,
                    label: Text(tag, style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.orange,
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    },
    ),
    );
  }
}
