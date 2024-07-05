import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:front/widget/app_bar.dart';
import 'package:provider/provider.dart';

import '../widget/bottom_bar.dart';

class GameDetailPage extends StatefulWidget {
  final int gameId;

  const GameDetailPage({Key? key, required this.gameId}) : super(key: key);

  @override
  _GameDetailPageState createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Map<String, dynamic> mockGame;
  late List<Map<String, dynamic>> mockLeaderboard;

  final String gameJson = '''
  {
    "id": 1,
    "name": "Mock Game 1",
    "description": "This is a description for Mock Game 1.",
    "media": {
      "fileName": "https://example.com/game_image.jpg"
    }
  }
  ''';

  final String leaderboardJson = '''
  [
    {"name": "Test1", "score": 0, "avatarUrl": "https://example.com/avatar.jpg"},
    {"name": "Test2", "score": 0, "avatarUrl": "https://example.com/avatar.jpg"},
    {"name": "Test3", "score": 0, "avatarUrl": "https://example.com/avatar.jpg"},
    {"name": "Test4", "score": 0, "avatarUrl": "https://example.com/avatar.jpg"},
    {"name": "Test5", "score": 0, "avatarUrl": "https://example.com/avatar.jpg"},
    {"name": "Test6", "score": 0, "avatarUrl": "https://example.com/avatar.jpg"},
    {"name": "Test7", "score": 0, "avatarUrl": "https://example.com/avatar.jpg"},
    {"name": "Test8", "score": 0, "avatarUrl": "https://example.com/avatar.jpg"},
    {"name": "Test9", "score": 0, "avatarUrl": "https://example.com/avatar.jpg"},
    {"name": "Test10", "score": 0, "avatarUrl": "https://example.com/avatar.jpg"}
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    mockGame = jsonDecode(gameJson);
    mockLeaderboard =
        List<Map<String, dynamic>>.from(jsonDecode(leaderboardJson));
  }

  Future<void> _onTournamentPageTapped() async {
    // action back to page make code
    final selectedPageModel =
        Provider.of<SelectedPageModel>(context, listen: false);
    selectedPageModel.changePage(
        TournamentsPage(searchQuery: mockGame['name']), 1);
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: TopAppBar(
          title: t.gameDetailsTitle,
          isAvatar: false,
        ),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: t.gameDetailsTab),
            Tab(text: t.gameScoreboardTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGameDetails(),
          _buildLeaderboard(),
        ],
      ),
    );
  }

  Widget _buildGameDetails() {
    var t = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mockGame['name'],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(
                    'http://10.0.2.2:8080/api/v1/images/yugiho.webp'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Description: ${mockGame['description']}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: _onTournamentPageTapped,
              child: Text(t.gameShowTournaments),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: mockLeaderboard.length,
      itemBuilder: (context, index) {
        final user = mockLeaderboard[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user['avatarUrl']),
          ),
          title: Text(user['name']),
          subtitle: Text('Score: ${user['score']}'),
          trailing: Text('#${index + 1}'),
        );
      },
    );
  }
}

class TournamentsPage extends StatelessWidget {
  final String? searchQuery;

  const TournamentsPage({Key? key, this.searchQuery}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tournois - ${searchQuery ?? ''}'),
      ),
      body: Center(
        child: Text('Liste des tournois pour le jeu: ${searchQuery ?? ''}'),
      ),
    );
  }
}
