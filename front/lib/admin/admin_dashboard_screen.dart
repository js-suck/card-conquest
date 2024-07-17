import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  int usersCount = 0;
  int tournamentsCount = 0;
  int guildsCount = 0;
  int gamesCount = 0;
  int tagsCount = 0;
  int matchesCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchCounts();
  }

  Future<void> _fetchCounts() async {
    String? token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      try {
        final responses = await Future.wait([
          _fetchList('users', token),
          _fetchList('tournaments', token),
          _fetchList('guilds', token),
          _fetchList('games', token),
          _fetchList('tags', token),
          _fetchList('matchs', token),
        ]);

        setState(() {
          usersCount = responses[0].length;
          tournamentsCount = responses[1].length;
          guildsCount = responses[2].length;
          gamesCount = responses[3].length;
          tagsCount = responses[4].length;
          matchesCount = responses[5].length;
          _isLoading = false;
        });
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<dynamic>> _fetchList(String endpoint, String token) async {
    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}$endpoint'),
      headers: {'Authorization': '$token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load list for $endpoint');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 2,
              children: [
                DashboardCard(
                  title: 'Users',
                  count: usersCount.toString(),
                  icon: Icons.person,
                  color: Colors.blue,
                ),
                DashboardCard(
                  title: 'Tournaments',
                  count: tournamentsCount.toString(),
                  icon: Icons.emoji_events,
                  color: Colors.orange,
                ),
                DashboardCard(
                  title: 'Guilds',
                  count: guildsCount.toString(),
                  icon: Icons.group,
                  color: Colors.green,
                ),
                DashboardCard(
                  title: 'Games',
                  count: gamesCount.toString(),
                  icon: Icons.videogame_asset,
                  color: Colors.red,
                ),
                DashboardCard(
                  title: 'Tags',
                  count: tagsCount.toString(),
                  icon: Icons.label,
                  color: Colors.purple,
                ),
                DashboardCard(
                  title: 'Matches',
                  count: matchesCount.toString(),
                  icon: Icons.credit_card_rounded,
                  color: Colors.teal,
                ),
              ],
            ),
          ),
          // Vous pouvez ajouter d'autres widgets ici si nécessaire
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;

  const DashboardCard({
    Key? key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 40.0, color: color),
              radius: 30,
            ),
            const SizedBox(height: 16.0),
            Text(count, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8.0),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}
