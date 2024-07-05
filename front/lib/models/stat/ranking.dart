import 'package:front/models/match/player.dart';

class Ranking {
  final Player user;
  final int score;
  final int rank;

  Ranking({
    required this.user,
    required this.score,
    required this.rank,
  });

  factory Ranking.fromJson(Map<String, dynamic> json) {
    return Ranking(
      user: Player.fromJson(json['User']),
      score: json['Score'],
      rank: json['Rank'],
    );
  }
}
