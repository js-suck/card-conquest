import 'package:front/models/user.dart';

class GamesRanking {
  final User user;
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
      user: User.fromJson(json['User']),
      gameId: json['GameID'],
      gameName: json['GameName'],
      score: json['Score'],
      rank: json['Rank'],
    );
  }
}
