class Organizer {
  final int? id;
  final String? username;
  final String? email;

  Organizer({
    required this.id,
    required this.username,
    this.email,
  });

  factory Organizer.fromJson(Map<String, dynamic> json) {
    return Organizer(
      id: json['ID'],
      username: json['username'],
      email: json['email'],
    );
  }
}
