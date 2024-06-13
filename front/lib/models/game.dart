class Game {
  final int id;
  final String name;
  final String imageUrl;

  Game({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['media'] != null
          ? 'http://10.0.2.2:8080/api/v1/images/${json['media']['file_name']}'
          : 'http://10.0.2.2:8080/api/v1/images/yugiho.webp',
    );
  }
}
