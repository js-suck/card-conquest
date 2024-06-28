import 'media.dart';

class User {
  final int? id;
  late final String username;
  late final String? email;
  final String? address;
  final String? phone;
  final String? role;
  final String? country;
  final Media? media;

  User({
    required this.id,
    required this.username,
    this.email,
    this.address,
    this.phone,
    this.role,
    this.country,
    this.media,
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
    );
  }
}
