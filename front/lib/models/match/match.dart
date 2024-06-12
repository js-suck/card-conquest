import 'package:front/models/match/player.dart';
import 'package:front/models/match/score.dart';
import 'package:front/models/match/tournament.dart';
import 'package:front/models/match/tournament_step.dart';

class Match {
  final int id;
  final Tournament tournament;
  final Player playerOne;
  final Player playerTwo;
  final DateTime startTime;
  final DateTime endTime;
  final TournamentStep tournamentStep;
  final int matchPosition;
  final List<Score>? scores;
  final String status;
  final Player winner;
  final String location;

  Match({
    required this.id,
    required this.tournament,
    required this.playerOne,
    required this.playerTwo,
    required this.startTime,
    required this.endTime,
    required this.tournamentStep,
    required this.matchPosition,
    this.scores,
    required this.status,
    required this.winner,
    required this.location,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['ID'],
      tournament: Tournament.fromJson(json['Tournament']),
      playerOne: Player.fromJson(json['PlayerOne']),
      playerTwo: Player.fromJson(json['PlayerTwo']),
      startTime: DateTime.parse(json['StartTime']),
      endTime: DateTime.parse(json['EndTime']),
      tournamentStep: TournamentStep.fromJson(json['TournamentStep']),
      matchPosition: json['MatchPosition'],
      scores: json['Scores'] != null
          ? (json['Scores'] as List).map((i) => Score.fromJson(i)).toList()
          : [],
      status: json['Status'],
      winner: Player.fromJson(json['Winner']),
      location: json['Location'],
    );
  }
}
