import 'guild.dart';
import 'media.dart';

class User {
  final int id;
  late final String username;
  late final String? email;
  final String? address;
  final String? phone;
  final String? role;
  final String? country;
  final Media? media;
  List<Guild>? guilds;

  User({
    this.id,
    required this.username,
    this.email,
    this.address,
    this.phone,
    this.role,
    this.country,
    this.media,
    this.guilds,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      address: json['address'],
      phone: json['phone'],
      role: json['role'],
      country: json['country'],
      media: json['media'] != null ? Media.fromJson(json['media']) : null,
      guilds: json['guilds'] != null && json['guilds'] is List
          ? List<Guild>.from(json['guilds'].map((item) => Guild.fromJson(item)))
          : null,
    );
  }

  bool IsAdmin() {
    return role == "admin";
  }

  bool IsUser() {
    return role == "user";
  }

  bool IsOrganizer() {
    return role == "organizer";
  }

  void setGuilds(List<Guild> guilds){
    this.guilds = guilds;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'address': address,
      'phone': phone,
      'role': role,
      'country': country,
      'media': media?.toJson(),
    };
  }
}
