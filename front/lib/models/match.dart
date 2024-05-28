import 'package:front/models/tournament.dart';

import '../generated/tournament.pb.dart';

class Match {
  final Tournament tournament;
  final Player playerOne;
  final Player playerTwo;
  final DateTime startTime;
  final DateTime endTime;
  final TournamentStep tournamentStep;
  final int matchPosition;
  final List<dynamic> scores;

  Match({
    required this.tournament,
    required this.playerOne,
    required this.playerTwo,
    required this.startTime,
    required this.endTime,
    required this.tournamentStep,
    required this.matchPosition,
    required this.scores,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      tournament: Tournament.fromJson(json['Tournament']),
      playerOne: Player.fromJson(json['PlayerOne']),
      playerTwo: Player.fromJson(json['PlayerTwo']),
      startTime: DateTime.parse(json['StartTime']),
      endTime: DateTime.parse(json['EndTime']),
      tournamentStep: TournamentStep.fromJson(json['TournamentStep']),
      matchPosition: json['MatchPosition'],
      scores: json['Scores'],
    );
  }
}
