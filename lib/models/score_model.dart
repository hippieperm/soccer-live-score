class Score {
  final TimeScore? fullTime;
  final TimeScore? halfTime;

  Score({this.fullTime, this.halfTime});

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      fullTime: json['fullTime'] != null ? TimeScore.fromJson(json['fullTime']) : null,
      halfTime: json['halfTime'] != null ? TimeScore.fromJson(json['halfTime']) : null,
    );
  }
}

class TimeScore {
  final int? home;
  final int? away;

  TimeScore({this.home, this.away});

  factory TimeScore.fromJson(Map<String, dynamic> json) {
    return TimeScore(
      home: json['home'],
      away: json['away'],
    );
  }
}
