import 'package:soccer/models/team_model.dart';
import 'package:soccer/models/score_model.dart';

class Match {
  final int id;
  final DateTime utcDate;
  final String status;
  final int? matchday;
  final String? stage;
  final Team homeTeam;
  final Team awayTeam;
  final Score? score;
  final Score? fullTime;
  final Score? halfTime;

  Match({
    required this.id,
    required this.utcDate,
    required this.status,
    this.matchday,
    this.stage,
    required this.homeTeam,
    required this.awayTeam,
    this.score,
    this.fullTime,
    this.halfTime,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] as int,
      utcDate: DateTime.parse(json['utcDate'] as String),
      status: json['status'] as String,
      matchday: json['matchday'] as int?,
      stage: json['stage'] as String?,
      homeTeam: Team.fromJson(json['homeTeam'] as Map<String, dynamic>),
      awayTeam: Team.fromJson(json['awayTeam'] as Map<String, dynamic>),
      score: json['score'] != null
          ? Score.fromJson(json['score'] as Map<String, dynamic>)
          : null,
      fullTime: json['score'] != null && json['score']['fullTime'] != null
          ? Score.fromJson(json['score']['fullTime'] as Map<String, dynamic>)
          : null,
      halfTime: json['score'] != null && json['score']['halfTime'] != null
          ? Score.fromJson(json['score']['halfTime'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'utcDate': utcDate.toIso8601String(),
      'status': status,
      'matchday': matchday,
      'stage': stage,
      'homeTeam': homeTeam.toJson(),
      'awayTeam': awayTeam.toJson(),
      'score': score?.toJson(),
    };
  }

  bool get isLive => status == 'LIVE' || status == 'IN_PLAY';
  bool get isFinished => status == 'FINISHED';
  bool get isScheduled => status == 'SCHEDULED' || status == 'TIMED';
}
