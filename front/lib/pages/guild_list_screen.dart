import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/guild.dart' as guild;
import '../service/guild_service.dart';

class GuildListScreen extends StatefulWidget {
  const GuildListScreen({super.key});

  @override
  _GuildListScreenState createState() => _GuildListScreenState();
}

class _GuildListScreenState extends State<GuildListScreen> {
  Future<List<guild.Guild>>? futureGuilds;
  final guildService = GuildService();
  final TextEditingController _searchController = TextEditingController();
  List<guild.Guild> _allGuilds = [];
  List<guild.Guild> _filteredGuilds = [];

  @override
  void initState() {
    super.initState();
    futureGuilds = guildService.fetchGuilds();
    futureGuilds!.then((guilds) {
      setState(() {
        _allGuilds = guilds;
        _filteredGuilds = guilds;
      });
    });
    _searchController.addListener(_filterGuilds);
  }

  void _filterGuilds() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredGuilds = _allGuilds.where((guild) {
        return guild.name!.toLowerCase().contains(query) ||
            guild.description!.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> join(BuildContext context, String guildId) async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'jwt_token');
    String? userID = await storage.read(key: 'user_id');

    if (token != null && userID != null) {
      bool success = await guildService.joinGuild(guildId, userID, token);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Joined guild successfully')),
        );

        Navigator.pushNamed(context, '/guild');

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join guild')),
        );
      }
    } else {
      // Handle the case where token or userID is null
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to retrieve token or user ID')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des guildes'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/guild/create');
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0), // Adjust the height to add space
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher une guilde...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              SizedBox(height: 10), // Add space below the search bar
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<guild.Guild>>(
          future: futureGuilds,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              return ListView.builder(
                itemCount: _filteredGuilds.length,
                itemBuilder: (context, index) {
                  var guild = _filteredGuilds[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          '${dotenv.env['MEDIA_URL']}${guild.media?.fileName}',
                        ),
                        radius: 25, // Adjust the size of the avatar
                      ),
                      title: Text(guild.name ?? ''),
                      subtitle: Text(guild.description ?? ''),
                      trailing: ElevatedButton(
                        onPressed: () {
                          join(context, guild.id.toString());
                        },
                        child: const Text('Rejoindre'),
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(child: Text('No guilds available'));
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/guild/create');
        },
        child: Icon(Icons.add),
        tooltip: 'Créer ma guilde',
      ),
    );
  }
}
