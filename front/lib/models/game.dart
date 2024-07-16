import 'media.dart';

class Game {
  final int id;
  final String name;
  final Media? media;

  Game({
    required this.id,
    required this.name,
    this.media,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      media: json['media'] != null ? Media.fromJson(json['media']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
    };
  }
}
