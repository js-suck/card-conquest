import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/generated/match.pb.dart';
import 'package:front/grpc/match_client.dart';
import 'package:front/notifier/theme_notifier.dart';
import 'package:front/service/match_service.dart';
import 'package:front/utils/custom_future_builder.dart';
import 'package:front/utils/custom_stream_builder.dart';
import 'package:front/widget/app_bar.dart';
import 'package:front/widget/bracket/match/head2head.dart';
import 'package:front/widget/bracket/match/summary.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:front/widget/expandable_fab.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MatchPage extends StatefulWidget {
  const MatchPage({Key? key});

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  late MatchClient matchClient;
  late MatchService matchService;
  late int matchId;
  final bool isBracket = true;
  bool isEditing = false;
  TextEditingController playerOneScoreController = TextEditingController();
  TextEditingController playerTwoScoreController = TextEditingController();

  final storage = FlutterSecureStorage();

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

  bool isAdmin(Map<String, dynamic> decodedToken) {
    // Fonction pour vérifier si l'utilisateur est administrateur
    return decodedToken['role'] == 'organizer';
  }

  Future<void> _updateScore(int userId, int score) async {
    final url = '${dotenv.env['API_URL']}matches/update/score';
    final token = await storage.read(key: 'jwt_token');

    var request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers['Authorization'] = '$token'
      ..fields['matchId'] = matchId.toString()
      ..fields['userId'] = userId.toString()
      ..fields['score'] = score.toString();

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Score updated successfully');
    } else {
      print('Failed to update score');
      print(response.statusCode);
      var responseData = await response.stream.bytesToString();
      print(responseData);
    }
  }

  Future<void> _editMatch(MatchResponse match) async {
    if (isEditing) {
      final newPlayerOneScore =
          int.tryParse(playerOneScoreController.text) ?? 0;
      final newPlayerTwoScore =
          int.tryParse(playerTwoScoreController.text) ?? 0;

      if (newPlayerOneScore != match.playerOne.score &&
          newPlayerOneScore != 0) {
        await _updateScore(match.playerOne.id, newPlayerOneScore);
      }
      if (newPlayerTwoScore != match.playerTwo.score &&
          newPlayerTwoScore != 0) {
        await _updateScore(match.playerTwo.id, newPlayerTwoScore);
      }
    }

    setState(() {
      isEditing = !isEditing;
    });
  }

  Future<void> _startMatch(MatchResponse match) async {
    final url = '${dotenv.env['API_URL']}matchs/$matchId';
    final token = await storage.read(key: 'jwt_token');
    var response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': '$token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'status': 'started'}),
    );
    if (response.statusCode == 200) {
      setState(() {
        match.status = 'started';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match started successfully')),
      );
    } else {
      print('Failed to start match: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start match: ${response.statusCode}'),
        ),
      );
    }
  }

  Future<void> _finishMatch(MatchResponse match) async {
    final url = '${dotenv.env['API_URL']}matchs/$matchId';
    final token = await storage.read(key: 'jwt_token');
    var response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': '$token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'status': 'finished'}),
    );
    if (response.statusCode == 200) {
      setState(() {
        match.status = 'finished';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match finished successfully')),
      );
    } else {
      print('Failed to finish match: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to finish match: ${response.statusCode}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final status = {
      'created': t.matchStatusCreated,
      'started': t.matchStatusStarted,
      'finished': t.matchStatusFinished,
    };

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
            // Initialisez les contrôleurs avec les scores actuels
            playerOneScoreController.text = match.playerOne.score.toString();
            playerTwoScoreController.text = match.playerTwo.score.toString();
            return Scaffold(
              appBar: TopAppBar(
                title: t.matchTitle,
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
                            bottom: 8.0,
                          ),
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
                                      image: matchInfo
                                                  .playerOne.media?.fileName !=
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
                                Text(
                                  '${t.matchRanking} ${match.playerOne.rank}.',
                                  style: const TextStyle(color: Colors.grey),
                                ),
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
                              children: isEditing
                                  ? [
                                      Container(
                                        width: 50,
                                        child: TextField(
                                          controller: playerOneScoreController,
                                          keyboardType: TextInputType.number,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: scoreColorPlayerOne,
                                          ),
                                        ),
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
                                      Container(
                                        width: 50,
                                        child: TextField(
                                          controller: playerTwoScoreController,
                                          keyboardType: TextInputType.number,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: scoreColorPlayerTwo,
                                          ),
                                        ),
                                      ),
                                    ]
                                  : [
                                      Text(
                                        '${match.playerOne.score}',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: scoreColorPlayerOne,
                                        ),
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
                            Text(
                              status[match.status]!,
                              style: TextStyle(
                                fontSize: 16,
                                color: match.status == 'started'
                                    ? Colors.redAccent
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 16.0,
                            left: 8.0,
                            right: 12.0,
                            bottom: 8.0,
                          ),
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
                                      image: matchInfo
                                                  .playerTwo.media?.fileName !=
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
                                Text(
                                  '${t.matchRanking} ${match.playerTwo.rank}.',
                                  style: const TextStyle(color: Colors.grey),
                                ),
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
                              tabs: [
                                Tab(text: t.matchSummary),
                                Tab(text: t.matchH2H),
                              ],
                            ),
                          ),
                          Flexible(
                            child: TabBarView(
                              children: [
                                Summary(match: match),
                                Head2Head(
                                  playerOne: match.playerOne,
                                  playerTwo: match.playerTwo,
                                  matchId: match.matchId,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              floatingActionButton: FutureBuilder<String?>(
                future: storage.read(key: 'jwt_token'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(); // Afficher un indicateur de chargement si nécessaire
                  }
                  if (snapshot.hasData) {
                    Map<String, dynamic> decodedToken =
                        JwtDecoder.decode(snapshot.data!);
                    if (isAdmin(decodedToken)) {
                      return ExpandableFab(
                        distance: 112.0,
                        children: [
                          if (match.status != 'finished' &&
                              match.status != 'created') ...[
                            FloatingActionButton(
                              heroTag: "editMatch$matchId",
                              onPressed: () => _editMatch(match),
                              tooltip: "Mode d'édition",
                              child: const Icon(Icons.edit),
                            ),
                            if (isEditing == false) ...[
                              FloatingActionButton(
                                heroTag: "finishMatch$matchId",
                                onPressed: () => _finishMatch(match),
                                tooltip: 'Finir le match',
                                child: const Icon(Icons.cancel),
                              ),
                            ]
                          ] else
                            FloatingActionButton(
                              heroTag: 'startMatch$matchId',
                              onPressed: () => _startMatch(match),
                              tooltip: 'Commencer le match',
                              child: const Icon(Icons.play_arrow),
                            ),
                        ],
                      );
                    }
                  }
                  return Container(); // Si l'utilisateur n'est pas admin, ne montrez pas le FAB
                },
              ),
            );
          },
        );
      },
    );
  }
}
