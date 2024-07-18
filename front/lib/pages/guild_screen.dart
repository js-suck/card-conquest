import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/models/user.dart' as userModel;
import 'package:front/pages/guild_list_screen.dart';
import 'package:provider/provider.dart';
import '../models/guild.dart' as guild;
import '../providers/user_provider.dart';
import '../service/guild_service.dart';
import 'chat_screen.dart';
import 'guild_update_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GuildView extends StatefulWidget {
  final int? guildId;
  final userModel.User? user;

  const GuildView({Key? key, this.guildId, this.user}) : super(key: key);

  @override
  _GuildViewState createState() => _GuildViewState();
}

class _GuildViewState extends State<GuildView> {
  bool isLoadingUser = true;
  bool isJoining = false;
  bool isLeaving = false;
  userModel.User? user;
  List<guild.Guild> userGuilds = [];
  List<int> userGuildIds = [];
  guild.Guild? currentGuild;

  final guildService = GuildService();

  @override
  void initState() {
    super.initState();
    _fetchUserAndGuilds();
  }

  Future<void> _fetchUserAndGuilds() async {
    user = Provider.of<UserProvider>(context, listen: false).user;

    userGuildIds = [];

    if (user != null) {
      userGuilds = await guildService.fetchUserGuild(user!.id);
      for (var guild in userGuilds) {
        userGuildIds.add(guild.id);
      }

      if (widget.guildId != null) {
        currentGuild = await guildService.fetchGuild(widget.guildId!);
      } else if (userGuilds.isNotEmpty) {
        currentGuild = await guildService.fetchGuild(userGuilds.first.id);
      }

      setState(() {
        isLoadingUser = false;
      });
    }
  }

  bool isUserAdmin(guild.Guild userGuild) {
    return userGuild.admins != null &&
        userGuild.admins!
            .any((admin) => admin['ID'].toString() == user!.id.toString());
  }

  bool isMemberAdmin(guild.Guild userGuild, int userId) {
    return userGuild.admins != null &&
        userGuild.admins!.any((admin) => admin['ID'] == userId);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.list,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/guilds');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: isLoadingUser
            ? const Center(child: CircularProgressIndicator())
            : currentGuild != null
                ? Column(
                    children: [
                      Card(
                        child: Padding(
                          padding:
                              const EdgeInsets.only(top: 30.0, bottom: 16.0),
                          child: Column(
                            children: <Widget>[
                              CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                  currentGuild!.media?.fileName != null
                                      ? '${dotenv.env['MEDIA_URL']}${currentGuild!.media?.fileName}'
                                      : 'https://avatar.iran.liara.run/public/${currentGuild!.id}',
                                ),
                                radius: 50,
                              ),
                              ListTile(
                                title: Center(
                                  child: Text(
                                    currentGuild!.name ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                subtitle: Center(
                                  child: Text(
                                    currentGuild!.description ?? '',
                                  ),
                                ),
                              ),
                              if (isUserAdmin(currentGuild!))
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                  ),
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GuildUpdateScreen(
                                            guild: currentGuild!),
                                      ),
                                    );
                                  },
                                ),
                              if (userGuilds.isEmpty &&
                                  !userGuildIds.contains(currentGuild?.id))
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          isJoining = true;
                                        });
                                        guildService
                                            .joinGuild(
                                                currentGuild!.id.toString(),
                                                user!.id.toString())
                                            .then((value) {
                                          if (value) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content:
                                                      Text('Joined guild')),
                                            );
                                            _fetchUserAndGuilds();
                                          } else {
                                            // Show an error message
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text('Failed to join guild')),
                                            );
                                          }
                                          setState(() {
                                            isJoining = false;
                                          });
                                        });
                                      },
                                      child: isJoining
                                          ? const CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            )
                                          : const Text('Join'),
                                    ),
                                    if (isJoining)
                                      CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                  ],
                                ),
                              if (userGuildIds.contains(currentGuild?.id))
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.chat),
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ChatClientScreen(
                                              guildId: currentGuild!.id ?? 0,
                                              username: user!.username,
                                              userId: user!.id,
                                              mediaUrl:
                                                  user!.media?.fileName ?? '',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.exit_to_app),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('Confirmation'),
                                                  content: Text(
                                                      'Are you sure you want to leave the guild?'),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: Text('Cancel'),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: Text('Confirm'),
                                                      onPressed: () async {
                                                        setState(() {
                                                          isLeaving = true;
                                                        });
                                                        bool success = await guildService
                                                            .leaveGuild(
                                                                currentGuild!.id
                                                                    .toString(),
                                                                user!.id
                                                                    .toString());
                                                        if (success) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    'Left guild')),
                                                          );
                                                          _fetchUserAndGuilds();
                                                        } else {
                                                          // Show an error message
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    'Failed to leave guild')),
                                                          );
                                                        }
                                                        setState(() {
                                                          isLeaving = false;
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
                                        ),
                                        if (isLeaving)
                                          CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: currentGuild!.players?.length ?? 0,
                          itemBuilder: (context, index) {
                            var player = currentGuild!.players![index];
                            bool isAdmin =
                                isMemberAdmin(currentGuild!, player['ID']);
                            return Material(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                    player['media'] != null &&
                                            player['media']['file_name'] != ''
                                        ? '${dotenv.env['API_URL']}images/${player['media']['file_name']}'
                                        : 'https://avatar.iran.liara.run/public/${player['ID']}',
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                        '#${index + 1}. ${player['username']}'),
                                    if (isAdmin)
                                      Icon(
                                        Icons.admin_panel_settings,
                                        color: Colors.yellow[700],
                                        size: 20.0,
                                      ),
                                  ],
                                ),
                                subtitle: Text('Score: ${player['score']}'),
                                trailing: isUserAdmin(currentGuild!) &&
                                        player['ID'] != user!.id
                                    ? IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title:
                                                    const Text('Confirmation'),
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
                                                      guildService.leaveGuild(
                                                              currentGuild!.id
                                                                  .toString(),
                                                              player['ID']
                                                                  .toString())
                                                          .then((value) {
                                                        if (value) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    'Removed user from guild')),
                                                          );
                                                          _fetchUserAndGuilds();
                                                        } else {
                                                          // Show an error message
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    'Failed to remove user from guild')),
                                                          );
                                                        }
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
                    ],
                  )
                : Center(child: Text(t.guildNoGuilds)),
      ),
    );
  }
}
