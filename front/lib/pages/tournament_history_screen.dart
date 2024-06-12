import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:front/widget/app_bar.dart';
import 'package:front/models/tournament.dart';
import 'package:front/widget/tournaments/all_tournaments_list.dart';

class TournamentHistoryPage extends StatefulWidget {
  const TournamentHistoryPage({Key? key}) : super(key: key);

  @override
  _TournamentHistoryPageState createState() => _TournamentHistoryPageState();
}

class _TournamentHistoryPageState extends State<TournamentHistoryPage> with SingleTickerProviderStateMixin {
  final storage = const FlutterSecureStorage();
  TabController? _tabController;
  String? userId;
  bool _isLoading = true;
  List<Tournament> upcomingTournaments = [];
  List<Tournament> pastTournaments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    String? token = await storage.read(key: 'jwt_token');
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      userId = decodedToken['user_id'].toString();
      await _fetchTournaments();
    }
  }

  Future<void> _fetchTournaments() async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/v1/tournaments/?UserId=$userId'),
      headers: {
        'Authorization': '$token',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> tournaments = json.decode(response.body);
      DateTime now = DateTime.now();
      setState(() {
        for (var tournament in tournaments) {
          Tournament tournamentObj = Tournament.fromJson(tournament);
          DateTime startDate = DateTime.parse(tournamentObj.startDate);
          if (startDate.isAfter(now)) {
            upcomingTournaments.add(tournamentObj);
          } else {
            pastTournaments.add(tournamentObj);
          }
        }
        _isLoading = false;
      });
    } else {
      _showError('Failed to load tournaments.');
    }
  }

  Future<void> _onTournamentTapped(int id) async {
    // Handle tournament tapped action
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TopAppBar(title: 'Historique'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tournois à venir'),
            Tab(text: 'Tournois Passés'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          AllTournamentsList(
            allTournaments: upcomingTournaments,
            onTournamentTapped: _onTournamentTapped,
          ),
          AllTournamentsList(
            allTournaments: pastTournaments,
            onTournamentTapped: _onTournamentTapped,
          ),
        ],
      ),
    );
  }
}
