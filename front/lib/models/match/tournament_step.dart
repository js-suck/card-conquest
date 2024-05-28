class TournamentStep {
  final String name;
  final int sequence;

  TournamentStep({
    required this.name,
    required this.sequence,
  });

  factory TournamentStep.fromJson(Map<String, dynamic> json) {
    return TournamentStep(
      name: json['Name'],
      sequence: json['Sequence'],
    );
  }
}
