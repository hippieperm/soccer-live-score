import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:soccer/models/match_model.dart';

// 캐시 엔트리 클래스
class _CacheEntry {
  final List<Match> data;
  final DateTime timestamp;

  _CacheEntry(this.data, this.timestamp);
}

class ApiService {
  final String _baseUrl = 'https://api.football-data.org/v4/';
  final String _apiKey =
      'd4ba84b5257e4148a586c2aa57a8a99a'; // TODO: Replace with your actual API key

  // 간단한 메모리 캐시 (실제로는 shared_preferences 사용 권장)
  final Map<String, _CacheEntry> _cache = {};

  // 캐시 유효 시간 (분)
  static const int _cacheValidMinutes = 5;

  // 주요 리그 코드 목록
  static const List<String> _majorLeagues = [
    'PL', // Premier League (프리미어리그)
    'PD', // Primera Division (라리가)
    'BL1', // Bundesliga (분데스리가)
    'SA', // Serie A (세리에 A)
    'FL1', // Ligue 1 (리그앙)
    'CL', // Champions League (챔피언스리그)
    'EL', // Europa League (유로파리그)
  ];

  // 캐시 유효성 확인
  bool _isCacheValid(String key) {
    if (!_cache.containsKey(key)) {
      return false;
    }

    final entry = _cache[key]!;
    final now = DateTime.now();
    final difference = now.difference(entry.timestamp);

    return difference.inMinutes < _cacheValidMinutes;
  }

  /// 특정 리그의 라이브 경기를 가져옵니다
  Future<List<Match>> _getLiveMatchesForLeague(String leagueCode) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/competitions/$leagueCode/matches?status=LIVE'),
        headers: {'X-Auth-Token': _apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> matchesList = data['matches'];
        return matchesList.map((json) => Match.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Match>> getLiveMatches() async {
    const cacheKey = 'live_matches_all';

    // 캐시 확인
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey]!.data;
    }

    try {
      // 모든 리그의 라이브 경기를 병렬로 가져오기
      final futures = _majorLeagues.map(
        (league) => _getLiveMatchesForLeague(league),
      );
      final results = await Future.wait(futures);

      // 모든 경기를 하나의 리스트로 합치기
      final allMatches = <Match>[];
      for (var matches in results) {
        allMatches.addAll(matches);
      }

      // 캐시에 저장
      _cache[cacheKey] = _CacheEntry(allMatches, DateTime.now());

      return allMatches;
    } catch (e) {
      // 캐시된 데이터가 있으면 반환
      if (_cache.containsKey(cacheKey)) {
        return _cache[cacheKey]!.data;
      }

      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to load live matches: $e');
    }
  }

  /// 특정 리그의 예정 경기를 가져옵니다
  Future<List<Match>> _getScheduledMatchesForLeague(
    String leagueCode,
    String dateFrom,
    String dateTo,
  ) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/competitions/$leagueCode/matches?status=SCHEDULED&dateFrom=$dateFrom&dateTo=$dateTo',
      );
      final response = await http.get(uri, headers: {'X-Auth-Token': _apiKey});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> matchesList = data['matches'];
        return matchesList.map((json) => Match.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Match>> getScheduledMatches() async {
    final today = DateTime.now();
    final oneWeekAhead = today.add(const Duration(days: 7));

    final dateFrom = today.toIso8601String().split('T').first;
    final dateTo = oneWeekAhead.toIso8601String().split('T').first;

    final cacheKey = 'scheduled_matches_all_$dateFrom';

    // 캐시 확인
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey]!.data;
    }

    try {
      // 모든 리그의 예정 경기를 병렬로 가져오기
      final futures = _majorLeagues.map(
        (league) => _getScheduledMatchesForLeague(league, dateFrom, dateTo),
      );
      final results = await Future.wait(futures);

      // 모든 경기를 하나의 리스트로 합치기
      final allMatches = <Match>[];
      for (var matches in results) {
        allMatches.addAll(matches);
      }

      // 캐시에 저장
      _cache[cacheKey] = _CacheEntry(allMatches, DateTime.now());

      return allMatches;
    } catch (e) {
      // 캐시된 데이터가 있으면 반환
      if (_cache.containsKey(cacheKey)) {
        return _cache[cacheKey]!.data;
      }

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

    try {
      // 모든 리그의 예정 경기를 병렬로 가져오기
      final futures = _majorLeagues.map(
        (league) => _getScheduledMatchesForLeague(league, dateFrom, dateTo),
      );
      final results = await Future.wait(futures);

      // 모든 경기를 하나의 리스트로 합치기
      final allMatches = <Match>[];
      for (var matches in results) {
        allMatches.addAll(matches);
      }

      return allMatches;
    } catch (e) {
      throw Exception('Failed to load more scheduled matches: $e');
    }
  }

  /// 특정 리그의 종료된 경기를 가져옵니다
  Future<List<Match>> _getFinishedMatchesForLeague(
    String leagueCode,
    String dateFrom,
    String dateTo,
  ) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/competitions/$leagueCode/matches?status=FINISHED&dateFrom=$dateFrom&dateTo=$dateTo',
      );
      final response = await http.get(uri, headers: {'X-Auth-Token': _apiKey});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> matchesList = data['matches'];
        return matchesList.map((json) => Match.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Match>> getFinishedMatches() async {
    final today = DateTime.now();
    final oneWeekAgo = today.subtract(const Duration(days: 7));

    final dateFrom = oneWeekAgo.toIso8601String().split('T').first;
    final dateTo = today.toIso8601String().split('T').first;

    final cacheKey = 'finished_matches_all_$dateFrom';

    // 캐시 확인
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey]!.data;
    }

    try {
      // 모든 리그의 종료된 경기를 병렬로 가져오기
      final futures = _majorLeagues.map(
        (league) => _getFinishedMatchesForLeague(league, dateFrom, dateTo),
      );
      final results = await Future.wait(futures);

      // 모든 경기를 하나의 리스트로 합치기
      final allMatches = <Match>[];
      for (var matches in results) {
        allMatches.addAll(matches);
      }

      // 시간순으로 정렬
      allMatches.sort((a, b) => b.utcDate.compareTo(a.utcDate));

      // 캐시에 저장
      _cache[cacheKey] = _CacheEntry(allMatches, DateTime.now());

      return allMatches;
    } catch (e) {
      // 캐시된 데이터가 있으면 반환
      if (_cache.containsKey(cacheKey)) {
        return _cache[cacheKey]!.data;
      }

      throw Exception('Failed to load finished matches: $e');
    }
  }

  Future<List<Match>> getMoreFinishedMatches(
    DateTime fromDate,
    DateTime toDate,
  ) async {
    final dateFrom = fromDate.toIso8601String().split('T').first;
    final dateTo = toDate.toIso8601String().split('T').first;

    try {
      // 모든 리그의 종료된 경기를 병렬로 가져오기
      final futures = _majorLeagues.map(
        (league) => _getFinishedMatchesForLeague(league, dateFrom, dateTo),
      );
      final results = await Future.wait(futures);

      // 모든 경기를 하나의 리스트로 합치기
      final allMatches = <Match>[];
      for (var matches in results) {
        allMatches.addAll(matches);
      }

      // 시간순으로 정렬
      allMatches.sort((a, b) => b.utcDate.compareTo(a.utcDate));

      return allMatches;
    } catch (e) {
      throw Exception('Failed to load more finished matches: $e');
    }
  }

  // 캐시 클리어
  void clearCache() {
    _cache.clear();
  }
}
