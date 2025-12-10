import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:soccer/models/match_model.dart';

class ApiService {
  final String _baseUrl = 'https://api.football-data.org/v4/';
  final String _apiKey =
      'd4ba84b5257e4148a586c2aa57a8a99a'; // TODO: Replace with your actual API key

  Future<List<Match>> getLiveMatches() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/competitions/PL/matches?status=LIVE'),
        headers: {'X-Auth-Token': _apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> matchesList = data['matches'];
        return matchesList.map((json) => Match.fromJson(json)).toList();
      } else {
        // 더 자세한 에러 정보 제공
        final errorMessage = response.body.isNotEmpty
            ? json.decode(response.body)['message'] ?? 'Unknown error'
            : 'HTTP ${response.statusCode}';
        throw Exception(
          'Failed to load live matches: $errorMessage (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to load live matches: $e');
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

    try {
      final response = await http.get(uri, headers: {'X-Auth-Token': _apiKey});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> matchesList = data['matches'];
        return matchesList.map((json) => Match.fromJson(json)).toList();
      } else {
        // 더 자세한 에러 정보 제공
        final errorMessage = response.body.isNotEmpty
            ? json.decode(response.body)['message'] ?? 'Unknown error'
            : 'HTTP ${response.statusCode}';
        throw Exception(
          'Failed to load scheduled matches: $errorMessage (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to load scheduled matches: $e');
    }
  }

  Future<List<Match>> getLiveAndScheduledMatches() async {
    try {
      // 라이브 경기와 예정 경기를 병렬로 가져오되, 하나라도 실패해도 계속 진행
      final results = await Future.wait([
        getLiveMatches().catchError((e) {
          print('라이브 경기 로드 실패: $e');
          return <Match>[];
        }),
        getScheduledMatches().catchError((e) {
          print('예정 경기 로드 실패: $e');
          return <Match>[];
        }),
      ]);

      final liveMatches = results[0];
      final scheduledMatches = results[1];

      // 둘 다 실패한 경우에만 에러 발생
      if (liveMatches.isEmpty && scheduledMatches.isEmpty) {
        throw Exception('라이브 경기와 예정 경기를 모두 불러오는데 실패했습니다');
      }

      // 라이브 경기를 먼저, 그 다음 경기 전 경기를 시간순으로 정렬
      final allMatches = [...liveMatches, ...scheduledMatches];
      allMatches.sort((a, b) => a.utcDate.compareTo(b.utcDate));

      return allMatches;
    } catch (e) {
      throw Exception('경기 정보를 불러오는데 실패했습니다: $e');
    }
  }

  Future<List<Match>> getMoreScheduledMatches(
    DateTime fromDate,
    int days,
  ) async {
    final toDate = fromDate.add(Duration(days: days));

    final dateFrom = fromDate.toIso8601String().split('T').first;
    final dateTo = toDate.toIso8601String().split('T').first;

    final uri = Uri.parse(
      '$_baseUrl/competitions/PL/matches?status=SCHEDULED&dateFrom=$dateFrom&dateTo=$dateTo',
    );

    final response = await http.get(uri, headers: {'X-Auth-Token': _apiKey});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> matchesList = data['matches'];
      return matchesList.map((json) => Match.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load more scheduled matches');
    }
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

  Future<List<Match>> getMoreFinishedMatches(
    DateTime fromDate,
    DateTime toDate,
  ) async {
    final dateFrom = fromDate.toIso8601String().split('T').first;
    final dateTo = toDate.toIso8601String().split('T').first;

    final uri = Uri.parse(
      '$_baseUrl/competitions/PL/matches?status=FINISHED&dateFrom=$dateFrom&dateTo=$dateTo',
    );

    final response = await http.get(uri, headers: {'X-Auth-Token': _apiKey});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> matchesList = data['matches'];
      return matchesList.map((json) => Match.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load more finished matches');
    }
  }
}
