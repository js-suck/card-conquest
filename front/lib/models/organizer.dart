class Organizer {
  final String username;
  final String email;

  Organizer({
    required this.username,
    required this.email,
  });

  factory Organizer.fromJson(Map<String, dynamic> json) {
    return Organizer(
      username: json['username'],
      email: json['email'],
    );
  }
}
