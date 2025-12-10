class Score {
  final int? home;
  final int? away;

  Score({this.home, this.away});

  factory Score.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Score();
    }
    return Score(home: json['home'] as int?, away: json['away'] as int?);
  }

  Map<String, dynamic> toJson() {
    return {'home': home, 'away': away};
  }

  bool get isEmpty => home == null && away == null;
}
