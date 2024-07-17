class Organizer {
  final int id;
  final String name;
  final String email;

  Organizer({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Organizer.fromJson(Map<String, dynamic> json) {
    return Organizer(
      id: json['ID'] ?? 0,
      name: json['username'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}