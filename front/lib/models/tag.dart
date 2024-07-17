import 'game.dart';
import 'match/tournament.dart';

class Tag {
  final int? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? label;
  final List<Tournament>? tournaments;
  final List<Game>? games;

  Tag({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.label,
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
      label: json['label'],
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'label': label,
      'tournaments': tournaments?.map((e) => e.toJson()).toList(),
      'games': games?.map((e) => e.toJson()).toList(),
    };
  }
}
