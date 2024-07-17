import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:front/models/user.dart';
import 'package:front/pages/guild_screen.dart';
import 'package:provider/provider.dart';

import '../models/guild.dart' as guild;
import '../models/guild.dart';
import '../providers/user_provider.dart';
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
    final t = AppLocalizations.of(context)!;

    if (token != null && userID != null) {
      bool success = await guildService.joinGuild(guildId, userID, token);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.guildJoinedSuccess)),
        );
        List<Guild> userGuilds =
            await guildService.fetchUserGuild(int.parse(userID));

        Provider.of<UserProvider>(context, listen: false)
            .updateUserGuilds(userGuilds);

        Navigator.pushNamed(context, '/guild');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.guildJoinFailed)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to retrieve token or user ID')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<UserProvider>(context).user;
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.guildList),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: t.guildSearch,
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
              SizedBox(height: 10),
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
                      radius: 25,
                    ),
                    title: Text(guild.name ?? ''),
                    subtitle: Text(guild.description ?? ''),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>  GuildView(guildId: guild.id)),
                      );
                    },
                  ));
                },
              );
            } else {
              return Center(child: Text(t.guildNoGuilds));
            }
          },
        ),
      ),
      floatingActionButton:
          user != null && (user.IsAdmin() || user.IsOrganizer())
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/guild/create');
                  },
                  child: Icon(Icons.add),
                  tooltip: t.guildCreateMine,
                )
              : null,
    );
  }
}
