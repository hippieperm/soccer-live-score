class Team {
  final int id;
  final String name;
  final String crest;

  Team({required this.id, required this.name, required this.crest});

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      crest: json['crest'] ?? '',
    );
  }
}
