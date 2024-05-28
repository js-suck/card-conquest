import 'games_ranking.dart';

class Stat {
  final int id;
  final String username;
  final String email;
  final int totalMatches;
  final int totalWins;
  final int totalLosses;
  final int totalScore;
  final int rank;
  final List<GamesRanking>? gamesRanking;

  Stat({
    required this.id,
    required this.username,
    required this.email,
    required this.totalMatches,
    required this.totalWins,
    required this.totalLosses,
    required this.totalScore,
    required this.rank,
    this.gamesRanking,
  });

  factory Stat.fromJson(Map<String, dynamic> json) {
    return Stat(
      id: json['ID'],
      username: json['username'],
      email: json['email'],
      totalMatches: json['TotalMatches'],
      totalWins: json['TotalWins'],
      totalLosses: json['TotalLosses'],
      totalScore: json['TotalScore'],
      rank: json['Rank'],
      gamesRanking: json['GamesRanking'] != null
          ? (json['GamesRanking'] as List)
              .map((i) => GamesRanking.fromJson(i))
              .toList()
          : [],
    );
  }
}
