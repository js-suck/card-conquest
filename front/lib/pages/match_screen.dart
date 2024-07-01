import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/generated/match.pb.dart';
import 'package:front/grpc/match_client.dart';
import 'package:front/main.dart';
import 'package:front/utils/custom_future_builder.dart';
import 'package:front/widget/app_bar.dart';
import 'package:provider/provider.dart';

import '../service/match_service.dart';
import '../utils/custom_stream_builder.dart';
import '../widget/bracket/match/head2head.dart';
import '../widget/bracket/match/summary.dart';

class MatchPage extends StatefulWidget {
  const MatchPage({super.key});

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  late MatchClient matchClient;
  late MatchService matchService;
  late int matchId;
  final bool isBracket = true;

  @override
  void initState() {
    super.initState();
    matchClient = MatchClient();
    matchService = MatchService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    matchId = ModalRoute.of(context)!.settings.arguments as int;
    matchClient.subscribeMatchUpdate(matchId);
    matchService.fetchMatch(matchId);
  }

  final status = {
    'created': 'Créé',
    'started': 'En cours',
    'finished': 'Terminé',
  };

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    Color scoreColorPlayerOne = context.themeColors.fontColor;
    Color scoreColorPlayerTwo = context.themeColors.fontColor;

    return CustomStreamBuilder<MatchResponse>(
        stream: matchClient.subscribeMatchUpdate(matchId),
        onLoaded: (match) {
          if (match.status == 'started') {
            scoreColorPlayerOne = Colors.red;
            scoreColorPlayerTwo = Colors.red;
          } else if (match.status == 'finished') {
            if (match.winnerId == match.playerOne.id) {
              scoreColorPlayerOne = Colors.green;
              scoreColorPlayerTwo = Colors.red;
            } else {
              scoreColorPlayerTwo = Colors.green;
              scoreColorPlayerOne = Colors.red;
            }
          }
          return CustomFutureBuilder(
              future: matchService.fetchMatch(matchId),
              onLoaded: (matchInfo) {
                return Scaffold(
                  appBar: const TopAppBar(
                    title: 'Match',
                    isPage: true,
                    isAvatar: false,
                    isSettings: false,
                  ),
                  body: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 16.0,
                                  left: 12.0,
                                  right: 8.0,
                                  bottom: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/player',
                                      arguments: {
                                        'player': match.playerOne,
                                        'isTournament': true
                                      });
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      width: 65,
                                      height: 65,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: matchInfo.playerOne.media
                                                      ?.fileName !=
                                                  ''
                                              ? NetworkImage(
                                                      '${dotenv.env['MEDIA_URL']}${matchInfo.playerOne.media?.fileName}')
                                                  as ImageProvider<Object>
                                              : const AssetImage(
                                                  'assets/images/avatar.png'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      match.playerOne.username,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight:
                                            match.winnerId == match.playerOne.id
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                      ),
                                    ),
                                    Text('Cla. ${match.playerOne.rank}.',
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              children: [
                                Text(
                                  '${matchInfo.startTime.day.toString().padLeft(2, '0')}/${matchInfo.startTime.month.toString().padLeft(2, '0')}/${matchInfo.startTime.year} ${matchInfo.startTime.hour.toString().padLeft(2, '0')}:${matchInfo.startTime.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '${match.playerOne.score}',
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: scoreColorPlayerOne),
                                    ),
                                    Text(
                                      ' - ',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: match.status == 'started'
                                            ? Colors.red
                                            : context.themeColors.fontColor,
                                      ),
                                    ),
                                    Text(
                                      '${match.playerTwo.score}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: scoreColorPlayerTwo,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(status[match.status]!,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: match.status == 'started'
                                            ? Colors.redAccent
                                            : Colors.grey)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 16.0,
                                  left: 8.0,
                                  right: 12.0,
                                  bottom: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/player',
                                      arguments: {
                                        'player': match.playerTwo,
                                        'isTournament': true
                                      });
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      width: 65,
                                      height: 65,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: matchInfo.playerTwo.media
                                                      ?.fileName !=
                                                  ''
                                              ? NetworkImage(
                                                      '${dotenv.env['MEDIA_URL']}${matchInfo.playerTwo.media?.fileName}')
                                                  as ImageProvider<Object>
                                              : const AssetImage(
                                                  'assets/images/avatar.png'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      match.playerTwo.username,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight:
                                            match.winnerId == match.playerTwo.id
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                      ),
                                    ),
                                    Text('Cla. ${match.playerTwo.rank}.',
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                          child: DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            Container(
                              height: 50,
                              color: isDarkMode
                                  ? Colors.black
                                  : const Color(0xff1a4ccb),
                              child: TabBar(
                                labelColor: context.themeColors.accentColor,
                                unselectedLabelColor: Colors.white,
                                // isScrollable: true,
                                tabs: const [
                                  Tab(text: 'Résumé'),
                                  // Tab(text: 'Stats'),
                                  // Tab(text: 'Point par point'),
                                  Tab(text: 'TÀT'),
                                ],
                              ),
                            ),
                            Flexible(
                              child: TabBarView(
                                children: [
                                  Summary(match: match),
                                  // const Center(child: Text('Stats')),
                                  // const Center(child: Text('Point par point')),
                                  Head2Head(
                                      playerOne: match.playerOne,
                                      playerTwo: match.playerTwo,
                                      matchId: match.matchId),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                );
              });
        });
  }
}
