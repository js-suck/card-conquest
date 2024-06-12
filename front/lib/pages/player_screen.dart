import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/generated/match.pb.dart' as tournament;
import 'package:front/service/match_service.dart';
import 'package:front/widget/app_bar.dart';
import 'package:front/widget/player/stats.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../utils/custom_future_builder.dart';
import '../widget/bracket/match/match_tiles.dart';

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
    final tournament.PlayerMatch player =
        args!['player'] as tournament.PlayerMatch;
    final bool isTournament = args['isTournament'] as bool;
    matchService.fetchFinishedMatchesOfPlayer(player.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;

    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    final tournament.PlayerMatch player =
        args!['player'] as tournament.PlayerMatch;
    final bool isTournament = args['isTournament'] as bool;
    return Scaffold(
      appBar: TopAppBar(
        title: player.username,
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
                      image: AssetImage(player.mediaUrl == ''
                          ? 'assets/images/avatar.png'
                          : player.mediaUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.username,
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
                Text(player.rank == 1
                    ? '${player.rank}er'
                    : '${player.rank}ème'),
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
                      child: const TabBar(
                        unselectedLabelColor: Colors.white,
                        tabs: [
                          Tab(text: 'Résultats'),
                          Tab(text: 'Statistiques'),
                        ],
                      ),
                    ),
                    Flexible(
                      child: TabBarView(
                        children: [
                          SingleChildScrollView(
                            child: CustomFutureBuilder(
                                future: matchService
                                    .fetchFinishedMatchesOfPlayer(player.id),
                                onLoaded: (matches) {
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
                                        player: player,
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
                          StatsWidget(playerId: player.id)
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
