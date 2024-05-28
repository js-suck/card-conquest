class Organizer {
  final String? username;
  final String? email;

  Organizer({
    this.username,
    this.email,
  });

  factory Organizer.fromJson(Map<String, dynamic> json) {
    return Organizer(
      name: json['username'] ?? '',
      email: json['email'] ?? '',
    );
  }
}