class Team {
  final int id;
  final String name;
  final String? shortName;
  final String? crest;
  final String? tla;

  Team({
    required this.id,
    required this.name,
    this.shortName,
    this.crest,
    this.tla,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as int,
      name: json['name'] as String,
      shortName: json['shortName'] as String?,
      crest: json['crest'] as String?,
      tla: json['tla'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'crest': crest,
      'tla': tla,
    };
  }
}
