import 'package:front/models/media.dart';

import 'game.dart';
import 'organizer.dart';

class Tournament {
  final int id;
  final String name;
  final String? description;
  final String? location;
  final Organizer organizer;
  final Game game;
  final DateTime startDate;
  final DateTime endDate;
  final Media? media;
  final int maxPlayers;
  final int playersRegistered;
  final List<String> tags;
  final String status;

  Tournament({
    required this.id,
    required this.name,
    this.description,
    this.location,
    required this.organizer,
    required this.game,
    required this.startDate,
    required this.endDate,
    this.media,
    required this.maxPlayers,
    required this.playersRegistered,
    required this.tags,
    required this.status,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      location: json['location'],
      organizer: Organizer.fromJson(json['Organizer']),
      game: Game.fromJson(json['game']),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      media: json['media'] != null ? Media.fromJson(json['media']) : null,
      maxPlayers: json['max_players'],
      playersRegistered: json['players_registered'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      status: json['status'] ?? 'unknown',
    );
  }
}
