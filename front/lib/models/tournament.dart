import 'game.dart';
import 'organizer.dart';

class Tournament {
  final int id;
  final String name;
  final String description;
  final String location;
  final String startDate;
  final String endDate;
  final String imageUrl;
  final int maxPlayers;
  final Organizer organizer;
  final Game game;
  final List<String> tags;

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.imageUrl,
    required this.maxPlayers,
    required this.organizer,
    required this.game,
    required this.tags,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      imageUrl: json['media'] != null
          ? 'http://10.0.2.2:8080/api/v1/images/${json['media']['file_name']}'
          : 'http://10.0.2.2:8080/api/v1/images/yugiho.webp',
      maxPlayers: json['max_players'] ?? 0,
      organizer: Organizer.fromJson(json['Organizer'] ?? {}),
      game: Game.fromJson(json['game'] ?? {}),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    );
  }
}


