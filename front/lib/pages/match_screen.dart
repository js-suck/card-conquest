import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool isOrganizer = false;
  DateTime selectedDateTime = DateTime.now();

  TextEditingController playerOneScoreController = TextEditingController();
  TextEditingController playerTwoScoreController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    matchClient = MatchClient();
    matchService = MatchService();
    storage.read(key: 'jwt_token').then((token) {
      setState(() {
        isOrganizer = matchService.isAdmin(token);
      });
    });
  }

  @override
  void dispose() {
    playerOneScoreController.dispose();
    playerTwoScoreController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    matchId = ModalRoute.of(context)!.settings.arguments as int;
    matchClient.subscribeMatchUpdate(matchId);
    matchService.fetchMatch(matchId);
  }

  Future<void> _editMatch(MatchResponse match) async {
    if (isEditing) {
      final newPlayerOneScore =
          int.tryParse(playerOneScoreController.text) ?? 0;
      final newPlayerTwoScore =
          int.tryParse(playerTwoScoreController.text) ?? 0;

      if (newPlayerOneScore != match.playerOne.score &&
          newPlayerOneScore != 0) {
        await matchService.updateScore(
            matchId, match.playerOne.id, newPlayerOneScore);
      }
      if (newPlayerTwoScore != match.playerTwo.score &&
          newPlayerTwoScore != 0) {
        await matchService.updateScore(
            matchId, match.playerTwo.id, newPlayerTwoScore);
      }
    }
    setState(() {
      isEditing = !isEditing;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      _selectTime(context, pickedDate);
    }
  }

  Future<void> _selectTime(BuildContext context, DateTime pickedDate) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
    );
    if (pickedTime != null) {
      final DateTime pickedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      setState(() {
        selectedDateTime = pickedDateTime;
      });
      _updateTime(pickedDateTime);
    }
  }

  Future<void> _updateTime(DateTime dateTime) async {
    final t = AppLocalizations.of(context)!;
    final token = await storage.read(key: 'jwt_token');
    String formattedDateTime = dateTime.toIso8601String();
    formattedDateTime = formattedDateTime.replaceFirst('.000', '.00Z');
    var data = {
      'startTime': formattedDateTime,
    };
    var response = await http.put(
      Uri.parse('${dotenv.env['API_URL']}bracket/matchs/$matchId'),
      headers: {
        HttpHeaders.authorizationHeader: '$token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Start time updated successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.successTimeUpdate),
        ),
      );
    } else {
      print('Failed to update start time');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.failTimeUpdate),
        ),
      );
    }
  }

  Future<void> _startMatch(MatchResponse match) async {
    final t = AppLocalizations.of(context)!;
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
        SnackBar(content: Text(t.startMatch)),
      );
    } else {
      print('Failed to start match: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.startMatchFailed),
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
            dateController.text = match.startDate.toString();
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
                            GestureDetector(
                              onTap: () {
                                if (isOrganizer) {
                                  _selectDate(context);
                                }
                              },
                              child: Text(
                                '${matchInfo.startTime.day.toString().padLeft(2, '0')}/${matchInfo.startTime.month.toString().padLeft(2, '0')}/${matchInfo.startTime.year} ${matchInfo.startTime.hour.toString().padLeft(2, '0')}:${matchInfo.startTime.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
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
                    return const Center(
                        child:
                            CircularProgressIndicator()); // Indicateur de chargement pendant la récupération du token
                  }
                  // Gestion des erreurs ou absence de données
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Container(); // Affichez rien en cas d'erreur ou si le token est absent
                  }
                  // Décodage du token et vérification des droits d'administration
                  final token = snapshot.data!;
                  final Map<String, dynamic> decodedToken =
                      JwtDecoder.decode(token);
                  if (!matchService.isAdminWithDecodedToken(decodedToken)) {
                    return Container(); // Ne pas afficher le FAB si l'utilisateur n'est pas admin
                  }
                  List<Widget> fabButtons = [];
                  if (match.status != 'finished' && match.status != 'created') {
                    fabButtons.add(
                      FloatingActionButton(
                        heroTag: "editMatch$matchId",
                        onPressed: () => _editMatch(match),
                        tooltip: "Mode d'édition",
                        child: const Icon(Icons.edit),
                      ),
                    );
                  }
                  if (match.status != 'finished' && match.status != 'started') {
                    fabButtons.add(
                      FloatingActionButton(
                        heroTag: 'startMatch$matchId',
                        onPressed: () => _startMatch(match),
                        tooltip: 'Commencer le match',
                        child: const Icon(Icons.play_arrow),
                      ),
                    );
                  }
                  return ExpandableFab(
                    distance: 112.0,
                    children: fabButtons,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
