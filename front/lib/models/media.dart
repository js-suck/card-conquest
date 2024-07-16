class Media {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String fileName;
  final String fileExtension;

  Media({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.fileName,
    required this.fileExtension,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      fileName: json['file_name'],
      fileExtension: json['file_extension'],
    );
  }

  toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'file_name': fileName,
      'file_extension': fileExtension,
    };
  }
}
