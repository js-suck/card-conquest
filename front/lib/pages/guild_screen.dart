import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/guild.dart' as guild;
import '../service/guild_service.dart';

class GuildView extends StatefulWidget {
  const GuildView({super.key});

  @override
  _GuildViewState createState() => _GuildViewState();
}

class _GuildViewState extends State<GuildView> {
  Future<guild.Guild?>? futureUserGuild;
  Future<List<guild.Guild>>? futureGuilds;
  String? connectedUserID;
  final guildService = GuildService();

  @override
  void initState() {
    super.initState();
    _initializeFutures();
  }

  Future<void> _initializeFutures() async {
    await _getUserId();
    _fetchAndFetchFullUserGuild().then((guild) {
      if (guild == null) {
        Navigator.pushReplacementNamed(context, '/guilds');
      } else {
        setState(() {
          futureUserGuild = Future.value(guild);
        });
      }
    });
    futureGuilds = guildService.fetchGuilds();
  }

  Future<void> _getUserId() async {
    const storage = FlutterSecureStorage();
    connectedUserID = await storage.read(key: 'user_id');
  }

  Future<guild.Guild?> _fetchAndFetchFullUserGuild() async {
    if (connectedUserID != null) {
      List<guild.Guild> userGuilds = await guildService.fetchUserGuild(connectedUserID!);
      if (userGuilds.isNotEmpty) {
        String guildId = userGuilds.first.id.toString();
        return await guildService.fetchGuild(int.parse(guildId));
      }
    }
    return null;
  }

  Future<void> join(BuildContext context, String guildId) async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'jwt_token');
    String? userID = connectedUserID; // Use the correct method to obtain the user ID

    if (token != null && userID != null) {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/guilds/$guildId/users/$userID'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          futureUserGuild = _fetchAndFetchFullUserGuild();
        });
      } else {
        // Handle error in joining
        throw Exception('Failed to join');
      }
    } else {
      // Handle the case where token or userID is null
      throw Exception('Failed to retrieve token or user ID');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ma guilde')),
      body: SafeArea(
        child: FutureBuilder<guild.Guild?>(
          future: futureUserGuild,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data != null) {
              var userGuild = snapshot.data!;
              var players = userGuild.players != null ? List<Map<String, dynamic>>.from(userGuild.players as Iterable) : [];
              players.sort((a, b) => b['score'].compareTo(a['score']));

              bool isMember = players.any((player) => player['ID'].toString() == connectedUserID);

              print("userGuild media: ${userGuild.media?.fileName}");

              return Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30.0, bottom: 16.0),
                      child: Column(
                        children: <Widget>[
                          CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                              '${dotenv.env['MEDIA_URL']}${userGuild.media?.fileName}',
                            ),
                            radius: 50,
                          ),
                          ListTile(
                            title: Center(
                              child: Text(
                                userGuild.name ?? '',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            subtitle: Center(
                              child: Text(userGuild.description ?? '',
                                  style: const TextStyle(color: Colors.white)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ElevatedButton(
                              onPressed: isMember
                                  ? null
                                  : () {
                                join(context, userGuild.id.toString());
                              },
                              child: Text(isMember ? 'Membre' : 'Rejoindre la guilde'),
                            ),
                          ),
                          if (isMember) // Si l'utilisateur est membre, affichez le bouton
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, '/chat/${userGuild.id}');
                              },
                              child: const Text('Rejoindre le chat', style: TextStyle(color: Colors.black)),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        var player = players[index];
                        return Material(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  "${dotenv.env['API_URL']}/images/" + player['media']['file_name']
                              ),
                            ),
                            title: Text('#${index + 1}. ${player['username']}'),
                            subtitle: Text('Score: ${player['score']}'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else {
              return Center(child: Text('No guilds available'));
            }
          },
        ),
      ),
    );
  }
}
