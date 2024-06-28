class Score {
  final int? playerId;
  final int? score;

  Score({
    required this.playerId,
    required this.score,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      playerId: json['PlayerID'],
      score: json['Score'],
    );
  }
}
