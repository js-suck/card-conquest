import '../media.dart';

class Player {
  final int? id;
  final String name;
  final String? email;
  final Media? media;

  Player({
    required this.id,
    required this.name,
    this.email,
    this.media,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['ID'],
      name: json['username'],
      email: json['email'],
      media: json['media'] != null ? Media.fromJson(json['media']) : null,
    );
  }
}
