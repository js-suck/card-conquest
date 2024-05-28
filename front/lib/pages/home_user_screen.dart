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
import 'package:front/widget/tournaments/recent_tournaments_list.dart';
import 'package:front/widget/tournaments/all_tournaments_list.dart';
import 'package:front/widget/games/games_list.dart';
import 'package:front/models/tournament.dart';
import 'package:front/models/game.dart';

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
  bool _isLoading = true;

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

    if (recentTournamentsResponse.statusCode == 200 &&
        gamesResponse.statusCode == 200) {
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
        _isLoading = false;
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildSectionTitle('Tournois récents'),
            RecentTournamentsList(
              recentTournaments: recentTournaments,
              onTournamentTapped: _onTournamentTapped,
            ),
            _buildSectionTitleWithButton('Les tournois', 'Voir les tournois', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TournamentsPage()),
              );
            }),
            AllTournamentsList(
              allTournaments: allTournaments.take(4).toList(),
              onTournamentTapped: _onTournamentTapped,
            ),
            _buildSectionTitleWithButton('Les jeux', 'Tous les jeux', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GamesPage()),
              );
            }),
            GamesList(games: games),
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
}
