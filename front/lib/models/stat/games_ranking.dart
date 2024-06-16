import 'package:front/models/match/player.dart';

class GamesRanking {
  final Player user;
  final int gameId;
  final String gameName;
  final int score;
  final int rank;

  GamesRanking({
    required this.user,
    required this.gameId,
    required this.gameName,
    required this.score,
    required this.rank,
  });

  factory GamesRanking.fromJson(Map<String, dynamic> json) {
    return GamesRanking(
      user: Player.fromJson(json['User']),
      gameId: json['GameID'],
      gameName: json['GameName'],
      score: json['Score'],
      rank: json['Rank'],
    );
  }
}
