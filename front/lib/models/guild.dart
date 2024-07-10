
import 'user.dart';
import 'media.dart';

class Guild {
  final int? id;
  final String? name;
  final String? description;
  final Media? media;
  List<Map<String,dynamic>>? players;

  Guild({
    required this.id,
    required this.name,
    required this.description,
    this.media,
    this.players,
  });

  factory Guild.fromJson(Map<String, dynamic> json) {

    print(json['media']);
    return Guild(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      media : json['media'] != null ? Media.fromJson(json['media']['media']) : null,
      players: json['players'] != null && json['players'] is List
          ? List<Map<String,dynamic>>.from(json['players'].map((item) => item))
          : null,
    );
  }
}