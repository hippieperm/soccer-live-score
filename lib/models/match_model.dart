import 'package:soccer/models/score_model.dart';
import 'package:soccer/models/team_model.dart';

class Match {
  final int id;
  final Team homeTeam;
  final Team awayTeam;
  final Score score;
  final String status;
  final DateTime utcDate;

  Match({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.score,
    required this.status,
    required this.utcDate,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      homeTeam: Team.fromJson(json['homeTeam']),
      awayTeam: Team.fromJson(json['awayTeam']),
      score: Score.fromJson(json['score']),
      status: json['status'],
      utcDate: DateTime.parse(json['utcDate']),
    );
  }
}
