import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:soccer/models/match_model.dart';
import 'package:soccer/services/api_service.dart';
import 'package:soccer/widgets/match_list.dart';
import 'package:soccer/screens/detail_screen.dart';

class FinishedMatchesScreen extends StatefulWidget {
  const FinishedMatchesScreen({super.key});

  @override
  State<FinishedMatchesScreen> createState() => _FinishedMatchesScreenState();
}

class _FinishedMatchesScreenState extends State<FinishedMatchesScreen> {
  final ApiService _apiService = ApiService();
  List<Match> _matches = [];
  bool _isLoading = true;
  String? _errorMessage;
  DateTime _lastLoadedDate = DateTime.now().subtract(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final matches = await _apiService.getFinishedMatches();
      if (matches.isNotEmpty) {
        final firstMatch = matches.first;
        _lastLoadedDate = firstMatch.utcDate;
      }
      setState(() {
        _matches = matches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '경기 정보를 불러오는데 실패했습니다: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreMatches() async {
    try {
      final toDate = _lastLoadedDate.subtract(const Duration(days: 1));
      final fromDate = toDate.subtract(const Duration(days: 7));

      final moreMatches = await _apiService.getMoreFinishedMatches(
        fromDate,
        toDate,
      );

      if (moreMatches.isNotEmpty) {
        final firstMatch = moreMatches.first;
        _lastLoadedDate = firstMatch.utcDate;
        setState(() {
          _matches = [...moreMatches, ..._matches];
          _matches.sort((a, b) => b.utcDate.compareTo(a.utcDate));
        });
      }
    } catch (e) {
      // 에러 발생 시 조용히 처리
    }
  }

  void _onMatchTap(Match match) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailScreen(match: match)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E27), Color(0xFF1A1F3A), Color(0xFF0A0E27)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 헤더
              _buildHeader(),
              // 경기 목록
              Expanded(
                child: _errorMessage != null
                    ? _buildErrorWidget()
                    : MatchList(
                        matches: _matches,
                        onMatchTap: _onMatchTap,
                        isLoading: _isLoading,
                        onLoadMore: _loadMoreMatches,
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton(
          onPressed: _loadMatches,
          backgroundColor: Colors.white.withOpacity(0.2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  '종료된 경기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.withOpacity(0.8),
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage ?? '오류가 발생했습니다',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadMatches,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
