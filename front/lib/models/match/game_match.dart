class GameMatch {
  final int id;
  final String name;

  GameMatch({
    required this.id,
    required this.name,
  });

  factory GameMatch.fromJson(Map<String, dynamic> json) {
    return GameMatch(
      id: json['ID'],
      name: json['name'],
    );
  }
}
