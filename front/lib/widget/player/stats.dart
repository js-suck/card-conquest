import 'package:flutter/material.dart';
import 'package:front/extension/theme_extension.dart';

import '../../service/stat_service.dart';
import '../../utils/custom_future_builder.dart';

class StatsWidget extends StatefulWidget {
  const StatsWidget({super.key, required this.playerId});

  final int playerId;

  @override
  State<StatsWidget> createState() => _StatsWidgetState();
}

class _StatsWidgetState extends State<StatsWidget> {
  late StatService statService;

  @override
  void initState() {
    super.initState();
    statService = StatService();
    statService.fetchStats(widget.playerId);
  }

  @override
  Widget build(BuildContext context) {
    return CustomFutureBuilder(
      future: statService.fetchStats(widget.playerId),
      onError: (error) {
        return Center(
            child: Text(error,
                style: TextStyle(color: context.themeColors.fontColor)));
      },
      onLoaded: (playerStats) {
        final playerRatio = playerStats.totalMatches > 0
            ? ((playerStats.totalWins / playerStats.totalMatches) * 100)
                .toStringAsFixed(2)
            : '0';
        return Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
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
                ),
                Expanded(
                    flex: 3,
                    child: Text('Victoires : ${playerStats.totalWins}')),
                Expanded(
                  flex: 2,
                  child: Container(
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
                ),
                Expanded(
                    flex: 3,
                    child: Text('Défaites : ${playerStats.totalLosses}'))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
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
                ),
                Expanded(
                  flex: 3,
                  child: Text('Ratio : $playerRatio%'),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
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
                ),
                Expanded(
                    flex: 3,
                    child: Text('Score Total : ${playerStats.totalScore}'))
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              decoration: BoxDecoration(
                color: context.themeColors.backgroundAccentColor,
              ),
              height: 40,
              width: double.infinity,
              child: const Center(
                child: Text(
                  'Classement par jeu',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (var game in playerStats.gamesRanking ?? [])
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
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
                              Icons.videogame_asset_rounded,
                              color: context.themeColors.backgroundColor,
                            ),
                          ),
                        ),
                        // display game name, rank and score
                        Row(
                          children: [
                            Text(
                              '${game.gameName} : ',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                                '${game.rank == 1 ? '${game.rank}er' : '${game.rank}ème'} - ${game.score} points')
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
