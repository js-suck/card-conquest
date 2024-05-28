import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:front/pages/tournaments_registration_screen.dart';
import 'package:front/pages/tournaments_screen.dart';
import 'package:front/pages/games_screen.dart';
import 'package:front/auth/login_screen.dart';
import 'package:front/widget/app_bar.dart';
import 'package:front/widget/bottom_bar.dart';

class Tournament {
  final int id;
  final String name;
  final String description;
  final String location;
  final String startDate;
  final String endDate;
  final String imageUrl;
  final int maxPlayers;
  final Organizer organizer;
  final Game game;
  final List<String> tags;

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.imageUrl,
    required this.maxPlayers,
    required this.organizer,
    required this.game,
    required this.tags,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      imageUrl: json['media'] != null
          ? 'http://10.0.2.2:8080/api/v1/images/${json['media']['file_name']}'
          : 'http://10.0.2.2:8080/api/v1/images/yugiho.webp',
      maxPlayers: json['max_players'] ?? 0,
      organizer: Organizer.fromJson(json['Organizer'] ?? {}),
      game: Game.fromJson(json['game'] ?? {}),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    );
  }
}

class Organizer {
  final int id;
  final String name;
  final String email;

  Organizer({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Organizer.fromJson(Map<String, dynamic> json) {
    return Organizer(
      id: json['ID'] ?? 0,
      name: json['username'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class Game {
  final int id;
  final String name;
  final String imageUrl;

  Game({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['media'] != null
          ? 'http://10.0.2.2:8080/api/v1/images/${json['media']['file_name']}'
          : 'http://10.0.2.2:8080/api/v1/images/yugiho.webp',
    );
  }
}

class HomeUserPage extends StatefulWidget {
  const HomeUserPage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomeUserPage> {
  final storage = const FlutterSecureStorage();
  List<Tournament> recentTournaments = [];
  List<Tournament> allTournaments = [];
  List<Game> games = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    String? token = await storage.read(key: 'jwt_token');
    final recentTournamentsResponse = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/v1/tournaments?WithRecents=true'),
      headers: {
        'Authorization': '$token',
      },
    );
    final gamesResponse = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/v1/games?WithTrendy=false'),
      headers: {
        'Authorization': '$token',
      },
    );

    if (recentTournamentsResponse.statusCode == 200 && gamesResponse.statusCode == 200) {
      final responseData = jsonDecode(recentTournamentsResponse.body);

      setState(() {
        recentTournaments = (responseData['recentTournaments'] as List)
            .map((data) => Tournament.fromJson(data))
            .toList();

        allTournaments = (responseData['allTournaments'] as List)
            .map((data) => Tournament.fromJson(data))
            .toList();

        games = (jsonDecode(gamesResponse.body) as List)
            .map((data) => Game.fromJson(data))
            .take(10)
            .toList();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _onTournamentTapped(int id) async {
    String? token = await storage.read(key: 'jwt_token');
    if (token != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RegistrationPage(tournamentId: id)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(title: 'Accueil', isAvatar: true, isPage: false),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSectionTitle('Tournois récents'),
            _buildHorizontalList(recentTournaments),
            _buildSectionTitleWithButton('Les tournois', 'Voir les tournois', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TournamentsPage()),
              );
            }),
            _buildVerticalList(allTournaments.take(4).toList()), // Limiter à 4 tournois
            _buildSectionTitleWithButton('Les jeux', 'Tous les jeux', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GamesPage()),
              );
            }),
            _buildHorizontalListGames(games),
          ],
        ),
      ),
      bottomNavigationBar: const BottomBar(),
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

  Widget _buildHorizontalList(List<Tournament> items) {
    return Container(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          var item = items[index];
          return GestureDetector(
            onTap: () => _onTournamentTapped(item.id),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(item.imageUrl),
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
                            item.name,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${item.startDate.split('T')[0]} - ${item.startDate.split('T')[1].substring(0, 5)}",
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalListGames(List<Game> items) {
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
                  image: NetworkImage(item.imageUrl),
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
                          item.name,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.67,
        ),
        itemBuilder: (context, index) {
          var item = items[index];
          return GestureDetector(
            onTap: () => _onTournamentTapped(item.id),
            child: Container(
              width: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      image: DecorationImage(
                        image: NetworkImage(item.imageUrl),
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
                          item.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${item.startDate.split('T')[0]} - ${item.startDate.split('T')[1].substring(0, 5)}",
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Wrap(
                          spacing: 2,
                          children: item.tags.map((tag) => Chip(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: const BorderSide(color: Colors.transparent),
                            ),
                            padding: EdgeInsets.zero,
                            label: Text(tag, style: const TextStyle(color: Colors.white)),
                            backgroundColor: Colors.orange,
                          )).toList(),
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
}
