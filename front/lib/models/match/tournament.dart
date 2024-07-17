import 'package:front/models/match/user.dart';
import 'package:front/models/media.dart';

import 'game_match.dart';

class Tournament {
  final int id;
  final String name;
  final String? description;
  final String? location;
  final Organizer organizer;
  final GameMatch game;
  final DateTime startDate;
  final DateTime endDate;
  final Media? media;
  final int maxPlayers;
  final int playersRegistered;
  final String status;
  final List<String>? tags;
  final double? latitude;
  final double? longitude;

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
    required this.status,
    this.tags,
    this.latitude,
    this.longitude,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      organizer: Organizer.fromJson(json['Organizer'] ?? {}),
      game: GameMatch.fromJson(json['game']),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      media: json['media'] != null ? Media.fromJson(json['media']) : null,
      maxPlayers: json['max_players'],
      playersRegistered: json['players_registered'],
      status: json['status'] ?? 'unknown',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
    );
  }

  toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'organizer': organizer.toJson(),
      'game': game.toJson(),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'media': media?.toJson(),
      'max_players': maxPlayers,
      'players_registered': playersRegistered,
      'status': status,
      'tags': tags,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
