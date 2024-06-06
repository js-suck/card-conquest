import 'package:flutter/material.dart';
import 'package:front/models/tournament.dart';
import 'package:front/pages/tournaments_registration_screen.dart';
import 'package:front/widget/app_bar.dart';
import 'package:front/widget/tournaments/all_tournaments_list.dart';
import 'package:front/widget/tournaments/recent_tournaments_list.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TournamentsPage extends StatefulWidget {
  const TournamentsPage({super.key});

  @override
  _TournamentsPageState createState() => _TournamentsPageState();
}

class _TournamentsPageState extends State<TournamentsPage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  List<Tournament> recentTournaments = [];
  List<Tournament> allTournaments = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    String? token = await _storage.read(key: 'jwt_token');
    final recentTournamentsResponse = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/v1/tournaments?WithRecents=true'),
      headers: {
        'Authorization': '$token',
      },
    );

    if (recentTournamentsResponse.statusCode == 200) {
      final responseData = jsonDecode(recentTournamentsResponse.body);

      setState(() {
        recentTournaments = (responseData['recentTournaments'] as List)
            .map((data) => Tournament.fromJson(data))
            .toList();

        allTournaments = (responseData['allTournaments'] as List)
            .map((data) => Tournament.fromJson(data))
            .toList();
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }


  Future<void> _onTournamentTapped(int id) async {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RegistrationPage(tournamentId: id)),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(title: 'Tournois'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Tournois récents',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            RecentTournamentsList(
              recentTournaments: recentTournaments,
              onTournamentTapped: _onTournamentTapped,
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Tous les tournois',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            AllTournamentsList(
              allTournaments: allTournaments,
              onTournamentTapped: _onTournamentTapped,
            ),
          ],
        ),
      ),
    );
  }
}
