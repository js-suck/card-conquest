import 'organizer.dart';
import 'game_match.dart';

class Tournament {
  final int id;
  final String name;
  final String description;
  final String location;
  final Organizer organizer;
  final GameMatch game;
  final DateTime startDate;
  final DateTime endDate;
  final dynamic media;
  final int maxPlayers;

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.organizer,
    required this.game,
    required this.startDate,
    required this.endDate,
    required this.media,
    required this.maxPlayers,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      location: json['location'],
      organizer: Organizer.fromJson(json['Organizer']),
      game: GameMatch.fromJson(json['game']),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      media: json['media'],
      maxPlayers: json['max_players'],
    );
  }
}
