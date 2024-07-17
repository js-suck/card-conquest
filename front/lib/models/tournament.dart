class Tournament {
  final int id;
  final String name;
  final String description;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final String imageFilename;
  final int maxPlayers;
  final List<dynamic> players; // Changed type to dynamic

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.imageFilename,
    required this.maxPlayers,
    required this.players,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      location: json['location'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      imageFilename: json['media']['file_name'],
      maxPlayers: json['max_players'] ?? 0,
      players: json['players'] ?? [],
    );
  }
}
