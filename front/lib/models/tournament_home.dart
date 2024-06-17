import 'package:front/models/match/user.dart';

import 'game.dart';
import 'media.dart';

class TournamentHome {
  final int id;
  final String name;
  final String description;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final Media? media;
  final int maxPlayers;
  final Organizer organizer;
  final Game game;
  final List<String> tags;
  final String status;

  TournamentHome({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    this.media,
    required this.maxPlayers,
    required this.organizer,
    required this.game,
    required this.tags,
    required this.status,
  });

  factory TournamentHome.fromJson(Map<String, dynamic> json) {
    return TournamentHome(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      media: json['media'] != null ? Media.fromJson(json['media']) : null,
      maxPlayers: json['max_players'] ?? 0,
      organizer: Organizer.fromJson(json['Organizer'] ?? {}),
      game: Game.fromJson(json['game'] ?? {}),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      status: json['status'] ?? 'unknown',
    );
  }
}
