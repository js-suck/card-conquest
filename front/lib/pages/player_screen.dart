import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/notifier/theme_notifier.dart';
import 'package:front/service/match_service.dart';
import 'package:front/utils/custom_future_builder.dart';
import 'package:front/widget/app_bar.dart';
import 'package:front/widget/bracket/match/match_tiles.dart';
import 'package:front/widget/player/stats.dart';
import 'package:provider/provider.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late MatchService matchService;

  @override
  void initState() {
    super.initState();
    matchService = MatchService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final player = args!['player'];
    final isTournament = args['isTournament'];
    final playerId = isTournament ? player.id : player.user.id;
    matchService.fetchFinishedMatchesOfPlayer(playerId);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final t = AppLocalizations.of(context)!;

    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    final player = args!['player'];
    final isTournament = args['isTournament'];

    final playerId = isTournament ? player.id : player.user.id;
    final playerName = isTournament ? player.username : player.user.username;
    final playerMedia = isTournament
        ? player.mediaUrl
        : player.user.media != null
            ? player.user.media.fileName
            : '';

    return Scaffold(
      appBar: TopAppBar(
        title: playerName,
        isPage: true,
        isAvatar: false,
        isSettings: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 100,
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(
                      left: 20, right: 10, top: 10, bottom: 10),
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: playerMedia != ''
                          ? CachedNetworkImageProvider(
                              '${dotenv.env['MEDIA_URL']}$playerMedia',
                            )
                          : CachedNetworkImageProvider(
                                  'https://avatar.iran.liara.run/public/${playerId}')
                              as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playerName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 20, right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: context.themeColors.invertedBackgroundColor,
                  ),
                  width: 40,
                  height: 40,
                  child: Center(
                    child: Icon(
                      Icons.leaderboard,
                      color: context.themeColors.backgroundColor,
                    ),
                  ),
                ),
                Text('${player.rank}${t.playerRankingPosition(player.rank)}'),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      color:
                          isDarkMode ? Colors.black : const Color(0xff1a4ccb),
                      child: TabBar(
                        unselectedLabelColor: Colors.white,
                        tabs: [
                          Tab(text: t.playerResults),
                          Tab(text: t.playerStatistics),
                        ],
                      ),
                    ),
                    Flexible(
                      child: TabBarView(
                        children: [
                          SingleChildScrollView(
                            child: CustomFutureBuilder(
                                future: matchService
                                    .fetchFinishedMatchesOfPlayer(playerId),
                                onLoaded: (matches) {
                                  if (matches.isEmpty) {
                                    return Center(
                                      child: Text(t.playerNoMatches),
                                    );
                                  }
                                  //if (isTournament) {
                                  final groupedMatches = groupBy(matches,
                                      (match) => match.tournament.name);

                                  List<Widget> tournamentWidgets = [];
                                  groupedMatches
                                      .forEach((tournamentName, matches) {
                                    tournamentWidgets.add(
                                      MatchTiles(
                                        matches: matches,
                                        isLastMatches: true,
                                        isScoreboard: true,
                                        player:
                                            isTournament ? player : player.user,
                                      ),
                                    );
                                  });

                                  return SingleChildScrollView(
                                    child: Column(
                                      children: tournamentWidgets,
                                    ),
                                  );
                                  /*} else {
                                        return MatchTiles(matches: snapshot.data ?? []);
                                      }
                                       */
                                }),
                          ),
                          StatsWidget(playerId: playerId)
                        ],
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
