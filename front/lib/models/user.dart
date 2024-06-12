class User {
  final int? id;
  final String? username;
  final String? email;

  User({
    required this.id,
    required this.username,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['ID'],
      username: json['username'],
      email: json['email'],
    );
  }
}
