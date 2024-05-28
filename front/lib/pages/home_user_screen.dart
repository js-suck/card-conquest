import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
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
  final List<String> tags ;

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
      id: json['id'],
      name: json['name'],
      description: json['description'],
      location: json['location'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      // imageUrl: 'http://10.0.2.2:8080/uploads/${json['media']['file_name']}',
      imageUrl: 'assets/images/img.png',
      maxPlayers: json['max_players'],
      organizer: Organizer.fromJson(json['organizer']),
      game: Game.fromJson(json['game']),
      tags: [...json['tags']],
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
      id: json['ID'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class Game {
  final int id;
  final String name;
  final String category;
  final String imageUrl;

  Game({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['ID'],
      name: json['name'],
      category: json['category'],
      // imageUrl: 'http://10.0.2.2:8080/uploads/${json['media']['file_name']}',
      imageUrl: 'assets/images/img.png',
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

  /*Future<void> _fetchData() async {
    final recentTournamentsResponse = await http.get(Uri.parse('http://10.0.2.2:8080/api/v1/tournaments'));
    final allTournamentsResponse = await http.get(Uri.parse('http://10.0.2.2:8080/api/v1/tournaments'));
    final gamesResponse = await http.get(Uri.parse('http://10.0.2.2:8080/api/v1/games'));

    if (recentTournamentsResponse.statusCode == 200 && allTournamentsResponse.statusCode == 200 && gamesResponse.statusCode == 200) {
      setState(() {
        recentTournaments = (jsonDecode(recentTournamentsResponse.body) as List)
            .map((data) => Tournament.fromJson(data))
            .toList();

        allTournaments = (jsonDecode(allTournamentsResponse.body) as List)
            .map((data) => Tournament.fromJson(data))
            .toList();

        games = (jsonDecode(gamesResponse.body) as List)
            .map((data) => Game.fromJson(data))
            .toList();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }*/

  Future<void> _fetchData() async {
    // Utilisez des données d'exemple pour l'instant
    setState(() {
      recentTournaments = [
        Tournament(
          id: 1,
          name: 'Tournoi des 4',
          description: 'Tournoi de 4 équipes',
          location: 'Paris',
          startDate: '2023-05-05T15:00:00',
          endDate: '2023-05-05T18:00:00',
          imageUrl: 'assets/images/img.png',
          maxPlayers: 16,
          organizer: Organizer(
            id: 1,
            name: 'Organizer 1',
            email: ' [email protected]',
          ),
          game: Game(
            id: 1,
            name: 'Game 1',
            category: 'Category 1',
            imageUrl: 'assets/images/img.png',
          ),
          tags: ['3v3', 'Cashprice'],
        ),
        Tournament(
          id: 2,
          name: 'Tournoi des 2',
          description: 'Tournoi de 2 équipes',
          location: 'Lyon',
          startDate: '2023-05-05T15:00:00',
          endDate: '2023-05-05T18:00:00',
          imageUrl: 'assets/images/img.png',
          maxPlayers: 8,
          organizer: Organizer(
            id: 2,
            name: 'Organizer 2',
            email: ' [email protected]',
          ),
          game: Game(
            id: 2,
            name: 'Game 2',
            category: 'Category 2',
            imageUrl: 'assets/images/img.png',
          ),
          tags: ['1v1', 'Casual'],
        ),

      ];

      allTournaments = [
        Tournament(
          id: 1,
          name: 'Tournoi des 4',
          description: 'Tournoi de 4 équipes',
          location: 'Paris',
          startDate: '2023-05-05T15:00:00',
          endDate: '2023-05-05T18:00:00',
          imageUrl: 'assets/images/img.png',
          maxPlayers: 16,
          organizer: Organizer(
            id: 1,
            name: 'Organizer 1',
            email: ' [email protected]',
          ),
          game: Game(
            id: 1,
            name: 'Game 1',
            category: 'Category 1',
            imageUrl: 'assets/images/img.png',
          ),
          tags: ['3v3', 'Cashprice'],
        ),
        Tournament(
          id: 2,
          name: 'Tournoi des 2',
          description: 'Tournoi de 2 équipes',
          location: 'Lyon',
          startDate: '2023-05-05T15:00:00',
          endDate: '2023-05-05T18:00:00',
          imageUrl: 'assets/images/img.png',
          maxPlayers: 8,
          organizer: Organizer(
            id: 2,
            name: 'Organizer 2',
            email: ' [email protected]',
          ),
          game: Game(
            id: 2,
            name: 'Game 2',
            category: 'Category 2',
            imageUrl: 'assets/images/img.png',
          ),
          tags: ['1v1', 'Casual'],
        ),
        Tournament(
          id: 3,
          name: 'Tournoi des 3',
          description: 'Tournoi de 3 équipes',
          location: 'Marseille',
          startDate: '2023-05-05T15:00:00',
          endDate: '2023-05-05T18:00:00',
          imageUrl: 'assets/images/img.png',
          maxPlayers: 12,
          organizer: Organizer(
            id: 3,
            name: 'Organizer 3',
            email: ' [email protected]',
          ),
          game: Game(
            id: 3,
            name: 'Game 3',
            category: 'Category 3',
            imageUrl: 'assets/images/img.png',
          ),
          tags: ['2v2', 'Ranked'],
        ),
        Tournament(
          id: 4,
          name: 'Tournoi des 5zebgfezbfdezbdgf',
          description: 'Tournoi de 5 équipes',
          location: 'Bordeaux',
          startDate: '2023-05-05T15:00:00',
          endDate: '2023-05-05T18:00:00',
          imageUrl: 'assets/images/img.png',
          maxPlayers: 20,
          organizer: Organizer(
            id: 4,
            name: 'Organizer 4',
            email: ' [email protected]',
          ),
          game: Game(
            id: 4,
            name: 'Game 4',
            category: 'Category 4',
            imageUrl: 'assets/images/img.png',
          ),
          tags: ['4v4', 'Ranked'],
        ),
        Tournament(
          id: 9,
          name: 'Tournoi des 6',
          description: 'Tournoi de 5 équipes',
          location: 'Bordeaux',
          startDate: '2023-05-05T15:00:00',
          endDate: '2023-05-05T18:00:00',
          imageUrl: 'assets/images/img.png',
          maxPlayers: 20,
          organizer: Organizer(
            id: 4,
            name: 'Organizer 4',
            email: ' [email protected]',
          ),
          game: Game(
            id: 4,
            name: 'Game 4',
            category: 'Category 4',
            imageUrl: 'assets/images/img.png',
          ),
          tags: ['4v4', 'Ranked'],
        ),


        // Ajoutez d'autres tournois ici
      ];

      games = [
        Game(
          id: 1,
          name: 'Waven',
          category: 'Aventure - MMORPG',
          imageUrl: 'assets/images/img.png',
        ),
        Game(
          id: 2,
          name: 'Hearthstone',
          category: 'Cartes - Stratégie',
          imageUrl: 'assets/images/img.png',
        ),
        Game(
          id: 3,
          name: 'League of Legends',
          category: 'MOBA',
          imageUrl: 'assets/images/img.png',
        ),
        Game(
          id: 4,
          name: 'Valorant',
          category: 'FPS',
          imageUrl: 'assets/images/img.png',
        ),
        // Ajoutez d'autres jeux ici
      ];
    });
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
      appBar: TopAppBar( title: 'Accueil', isAvatar: true, isPage: false),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSectionTitle('Tournois récent'),
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
                    //image: NetworkImage(item.imageUrl),
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
                  //image: NetworkImage(item.imageUrl),
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
                          item.name,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          item.category,
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
                        //image: NetworkImage(item.imageUrl),
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
                              side: BorderSide(color: Colors.transparent),
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
