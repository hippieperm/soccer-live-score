import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:soccer/models/match_model.dart';

class ApiService {
  final String _baseUrl = 'https://api.football-data.org/v4/';
  final String _apiKey =
      'd4ba84b5257e4148a586c2aa57a8a99a'; // TODO: Replace with your actual API key

  Future<List<Match>> getLiveMatches() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/competitions/PL/matches?status=LIVE'),
      headers: {'X-Auth-Token': _apiKey},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> matchesList = data['matches'];
      return matchesList.map((json) => Match.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load live matches');
    }
  }

  Future<List<Match>> getScheduledMatches() async {
    final today = DateTime.now();
    final oneWeekAhead = today.add(const Duration(days: 7));

    final dateFrom = today.toIso8601String().split('T').first;
    final dateTo = oneWeekAhead.toIso8601String().split('T').first;

    final uri = Uri.parse(
      '$_baseUrl/competitions/PL/matches?status=SCHEDULED&dateFrom=$dateFrom&dateTo=$dateTo',
    );

    final response = await http.get(uri, headers: {'X-Auth-Token': _apiKey});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> matchesList = data['matches'];
      return matchesList.map((json) => Match.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load scheduled matches');
    }
  }

  Future<List<Match>> getLiveAndScheduledMatches() async {
    final results = await Future.wait([
      getLiveMatches(),
      getScheduledMatches(),
    ]);

    final liveMatches = results[0];
    final scheduledMatches = results[1];

    // 라이브 경기를 먼저, 그 다음 경기 전 경기를 시간순으로 정렬
    final allMatches = [...liveMatches, ...scheduledMatches];
    allMatches.sort((a, b) => a.utcDate.compareTo(b.utcDate));

    return allMatches;
  }

  Future<List<Match>> getFinishedMatches() async {
    final today = DateTime.now();
    final oneWeekAgo = today.subtract(const Duration(days: 7));

    final dateFrom = oneWeekAgo.toIso8601String().split('T').first;
    final dateTo = today.toIso8601String().split('T').first;

    final uri = Uri.parse(
      '$_baseUrl/competitions/PL/matches?status=FINISHED&dateFrom=$dateFrom&dateTo=$dateTo',
    );

    final response = await http.get(uri, headers: {'X-Auth-Token': _apiKey});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> matchesList = data['matches'];
      return matchesList.map((json) => Match.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load finished matches');
    }
  }
}
