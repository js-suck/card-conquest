import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../generated/chat.pb.dart' as chatpb;
import '../models/guild.dart' as guild;
import '../models/user.dart' as userModel;
import '../notifier/theme_notifier.dart';
import '../service/guild_service.dart';
import '../service/user_service.dart';
import 'chat_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'guild_update_screen.dart';

class GuildView extends StatefulWidget {
  const GuildView({super.key});

  @override
  _GuildViewState createState() => _GuildViewState();
}

class _GuildViewState extends State<GuildView> {
  Future<guild.Guild?>? futureUserGuild;
  Future<List<guild.Guild>>? futureGuilds;
  late userModel.User userConnected;
  final guildService = GuildService();
  final userService = UserService();
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _initializeFutures();
  }

  Future<void> _initializeFutures() async {
    final userId = await _getUserId();
    if (userId == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final user = await userService.fetchUser(userId);
      setState(() {
        userConnected = user;
        isLoadingUser = false;
      });
    } catch (e) {
      print('Error fetching user: $e');
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    _fetchAndFetchFullUserGuild(userId).then((guild) {
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

  Future<int?> _getUserId() async {
    const storage = FlutterSecureStorage();
    String? userId = await storage.read(key: 'user_id');
    if (userId != null) {
      return int.tryParse(userId);
    }
    return null;
  }

  Future<guild.Guild?> _fetchAndFetchFullUserGuild(int userId) async {
    List<guild.Guild> userGuilds = await guildService.fetchUserGuild(userId);
    if (userGuilds.isNotEmpty) {
      String guildId = userGuilds.first.id.toString();
      return await guildService.fetchGuild(int.parse(guildId));
    }
    return null;
  }

  Future<void> join(BuildContext context, String guildId) async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'jwt_token');
    String? userID = userConnected.id.toString();

    if (token != null && userID != null) {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/guilds/$guildId/users/$userID'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          futureUserGuild = _fetchAndFetchFullUserGuild(userConnected.id);
        });
      } else {
        throw Exception('Failed to join');
      }
    } else {
      throw Exception('Failed to retrieve token or user ID');
    }
  }

  isUserAdmin(guild.Guild userGuild) {
    return userGuild.admins != null &&
        userGuild.admins!.any(
            (admin) => admin['ID'].toString() == userConnected.id.toString());
  }

  isMemberAdmin(guild.Guild userGuild, int userId) {
    return userGuild.admins != null &&
        userGuild.admins!.any((admin) => admin['ID'] == userId);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.guildUserGuild,
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.list,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/guilds');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: isLoadingUser
            ? const Center(child: CircularProgressIndicator())
            : FutureBuilder<guild.Guild?>(
                future: futureUserGuild,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data != null) {
                    var userGuild = snapshot.data!;
                    var players = userGuild.players != null
                        ? List<Map<String, dynamic>>.from(
                            userGuild.players as Iterable)
                        : [];
                    players.sort((a, b) => b['score'].compareTo(a['score']));

                    bool isMember = players.any((player) =>
                        player['ID'].toString() == userConnected.id.toString());

                    return Column(
                      children: [
                        Card(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 30.0, bottom: 16.0),
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  subtitle: Center(
                                    child: Text(
                                      userGuild.description ?? '',
                                    ),
                                  ),
                                ),
                                if (isUserAdmin(userGuild))
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              GuildUpdateScreen(
                                                  guild: userGuild),
                                        ),
                                      );
                                    },
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: ElevatedButton(
                                    onPressed: isMember
                                        ? null
                                        : () {
                                            join(context,
                                                userGuild.id.toString());
                                          },
                                    child: Text(isMember
                                        ? t.guildMember
                                        : t.guildUserJoindGuild),
                                  ),
                                ),
                                if (isMember)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ChatClientScreen(
                                            guildId: userGuild.id ?? 0,
                                            username: userConnected.username,
                                            userId: userConnected.id,
                                            mediaUrl:
                                                userConnected.media?.fileName ??
                                                    '',
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(t.guildChat,
                                        style: TextStyle(color: Colors.black)),
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
                              bool isAdmin = isMemberAdmin(userGuild, player['ID']);
                              print('isAdmin: $isAdmin');
                              return Material(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      "${dotenv.env['API_URL']}images/${player['media']['file_name']}",
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Text('#${index + 1}. ${player['username']}'),
                                      if (isAdmin)
                                        Icon(
                                          Icons.admin_panel_settings,
                                          color: Colors.yellow[700],
                                          size: 20.0,
                                        ),
                                    ],
                                  ),
                                  subtitle: Text('Score: ${player['score']}'),
                                  trailing: isUserAdmin(userGuild) && player['ID'] != userConnected.id
                                      ? IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      'Confirmation'),
                                                  content: Text(
                                                      t.guildConfirmUserGuild),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: Text(t.cancel),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: Text(t.confirm),
                                                      onPressed: () {
                                                        guildService
                                                            .leaveGuild(
                                                                userGuild.id
                                                                    .toString(),
                                                                player['ID']
                                                                    .toString())
                                                            .then((_) {
                                                          setState(() {
                                                            futureUserGuild =
                                                                _fetchAndFetchFullUserGuild(
                                                                    userConnected
                                                                        .id);
                                                          });
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                        if (isMember)
                          IconButton(
                            icon: const Icon(
                              Icons.exit_to_app,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirmation'),
                                    content: Text(t.guildConfirmLeaveGuild),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(t.cancel),
                                        onPressed: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(builder: (context) {
                                            return GuildView();
                                          }));
                                        },
                                      ),
                                      TextButton(
                                        child: Text(t.confirm),
                                        onPressed: () {
                                          guildService
                                              .leaveGuild(
                                                  userGuild.id.toString(),
                                                  userConnected.id.toString())
                                              .then((value) {
                                            Navigator.pushReplacementNamed(
                                                context, '/guilds');
                                          });
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                      ],
                    );
                  } else {
                    return Center(child: Text(t.guildNoGuilds));
                  }
                },
              ),
      ),
    );
  }
}
