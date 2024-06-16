import 'game.dart';
import 'match/tournament.dart';

class Tag {
  final int? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? name;
  final List<Tournament>? tournaments;
  final List<Game>? games;

  Tag({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.name,
    this.tournaments,
    this.games,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      name: json['name'],
      tournaments: json['tournaments'] != null
          ? (json['tournaments'] as List)
              .map((i) => Tournament.fromJson(i))
              .toList()
          : null,
      games: json['games'] != null
          ? (json['games'] as List).map((i) => Game.fromJson(i)).toList()
          : null,
    );
  }
}