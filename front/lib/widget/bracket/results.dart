import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/generated/tournament.pb.dart' as tournament;
import 'package:front/models/match.dart' as match;
import 'package:front/widget/bracket/match/match_tiles.dart';
import 'package:http/http.dart' as http;

import '../../generated/tournament.pb.dart';
import '../../models/game_match.dart';
import 'bracket.dart';

Future<List<match.Match>> fetchMatches(tournamentId) async {
  final storage = new FlutterSecureStorage();
  String? token = await storage.read(key: 'jwt_token');

  final response = await http.get(
    Uri.parse('${dotenv.env['API_URL']}matchs?tournamentId=$tournamentId'),
    headers: {
      HttpHeaders.authorizationHeader: '$token',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to load matches');
  }
  final List<dynamic> responseJson = jsonDecode(response.body);
  return responseJson.map((json) => match.Match.fromJson(json)).toList();
}

class Results extends StatefulWidget {
  const Results({super.key, required this.tournamentId});
  final int tournamentId;

  @override
  State<Results> createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  @override
  void initState() {
    super.initState();
    fetchMatches(_tournamentId);
  }

  get _tournamentId => widget.tournamentId;

  final List<tournament.Match> matches = [
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Alcaraz C',
        userId: '1',
        score: 2,
      ),
      playerTwo: tournament.Player(
        username: 'Medvedev D',
        userId: '5',
        score: 0,
      ),
      status: 'finished',
      winnerId: 1,
    ),
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Federer R',
        userId: '3',
        score: 2,
      ),
      playerTwo: tournament.Player(
        username: 'Nadal R',
        userId: '7',
        score: 1,
      ),
      status: 'finished',
      winnerId: 3,
    ),
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Djokovic N',
        userId: '9',
        score: 2,
      ),
      playerTwo: tournament.Player(
        username: 'Shapovalov D',
        userId: '12',
        score: 0,
      ),
      status: 'finished',
      winnerId: 9,
    ),
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Auger-Aliassime F',
        userId: '14',
        score: 2,
      ),
      playerTwo: tournament.Player(
        username: 'Monfils G',
        userId: '16',
        score: 0,
      ),
      status: 'finished',
      winnerId: 14,
    ),
    tournament.Match(
      playerOne: tournament.Player(
        username: 'Rublev A',
        userId: '6',
        score: 0,
      ),
      playerTwo: tournament.Player(
        username: 'Sinner J',
        userId: '2',
        score: 2,
      ),
      status: 'finished',
      winnerId: 2,
    ),
  ];

  final List<Matcha> oldMatches = [
    Matcha(
      player1: 'Alcaraz C',
      player2: 'Medvedev D',
      playerOneId: 1,
      playerTwoId: 5,
      status: 'finished',
      score1: '2',
      score2: '0',
      winnerId: 1,
    ),
    Matcha(
      player1: 'Federer R',
      player2: 'Nadal R',
      playerOneId: 3,
      playerTwoId: 7,
      status: 'finished',
      score1: '2',
      score2: '1',
      winnerId: 3,
    ),
    Matcha(
      player1: 'Djokovic N',
      player2: 'Shapovalov D',
      playerOneId: 9,
      playerTwoId: 12,
      status: 'finished',
      score1: '2',
      score2: '0',
      winnerId: 9,
    ),
    Matcha(
      player1: 'Auger-Aliassime F',
      player2: 'Monfils G',
      playerOneId: 14,
      playerTwoId: 15,
      status: 'finished',
      score1: '1',
      score2: '2',
      winnerId: 15,
    ),
    Matcha(
      player1: 'Rublev A',
      player2: 'Sinner J',
      playerOneId: 13,
      playerTwoId: 21,
      status: 'finished',
      score1: '0',
      score2: '2',
      winnerId: 21,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        debugPrint(snapshot.data?[0].toString());
        return MatchTiles(
          matches: oldMatches,
        );
      },
      future: fetchMatches(_tournamentId),
    );
  }
}
