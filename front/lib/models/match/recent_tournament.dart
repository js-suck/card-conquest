import 'package:front/models/match/game_match.dart';

import '../media.dart';
import 'organizer.dart';

class RecentTournament {
  final int id;
  final String name;
  final String description;
  final String location;
  final String startDate;
  final String endDate;
  final Media? media;
  final int maxPlayers;
  final Organizer organizer;
  final GameMatch game;
  final List<String> tags;
  final String status;

  RecentTournament({
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

  factory RecentTournament.fromJson(Map<String, dynamic> json) {
    return RecentTournament(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      media: json['media'] != null ? Media.fromJson(json['media']) : null,
      maxPlayers: json['max_players'] ?? 0,
      organizer: Organizer.fromJson(json['Organizer'] ?? {}),
      game: GameMatch.fromJson(json['game'] ?? {}),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      status: json['status'] ?? 'unknown',
    );
  }
}
