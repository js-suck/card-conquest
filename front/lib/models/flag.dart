class Flag {
  late bool enabled;
  final String name;

  Flag({
    required this.enabled,
    required this.name,
  });

  factory Flag.fromJson(Map<String, dynamic> json) {
    return Flag(
      enabled: json['enabled'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  toJson() {
    return {
      'enabled': enabled,
      'name': name,
    };
  }
}
