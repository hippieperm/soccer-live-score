import 'package:flutter/material.dart';
import 'package:soccer/models/match_model.dart';
import 'package:soccer/widgets/match_card.dart';

class MatchList extends StatefulWidget {
  final List<Match> matches;
  final Function(Match) onMatchTap;
  final bool isLoading;
  final Function()? onLoadMore;

  const MatchList({
    super.key,
    required this.matches,
    required this.onMatchTap,
    this.isLoading = false,
    this.onLoadMore,
  });

  @override
  State<MatchList> createState() => _MatchListState();
}

class _MatchListState extends State<MatchList> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        widget.onLoadMore != null) {
      setState(() {
        _isLoadingMore = true;
      });
      widget.onLoadMore!().then((_) {
        if (mounted) {
          setState(() {
            _isLoadingMore = false;
          });
        }
      });
    }
  }

  bool _isDifferentDay(Match current, Match? previous) {
    if (previous == null) return true;
    final currentKorea = current.utcDate.add(const Duration(hours: 9));
    final previousKorea = previous.utcDate.add(const Duration(hours: 9));
    return currentKorea.year != previousKorea.year ||
        currentKorea.month != previousKorea.month ||
        currentKorea.day != previousKorea.day;
  }

  String _getDayLabel(DateTime utcDate) {
    final koreaDate = utcDate.add(const Duration(hours: 9));
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final now = DateTime.now().toUtc().add(const Duration(hours: 9));
    final today = DateTime(now.year, now.month, now.day);
    final matchDate = DateTime(koreaDate.year, koreaDate.month, koreaDate.day);

    if (matchDate == today) {
      return '오늘 (${weekdays[koreaDate.weekday - 1]})';
    } else if (matchDate == today.add(const Duration(days: 1))) {
      return '내일 (${weekdays[koreaDate.weekday - 1]})';
    } else {
      return '${koreaDate.month}/${koreaDate.day} (${weekdays[koreaDate.weekday - 1]})';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.matches.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (widget.matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_soccer,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '진행 중이거나 예정된 경기가 없습니다',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 120),
      itemCount: widget.matches.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.matches.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        }

        final match = widget.matches[index];
        final previousMatch = index > 0 ? widget.matches[index - 1] : null;
        final showDivider = _isDifferentDay(match, previousMatch);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDivider) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.red.withOpacity(0.5),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        _getDayLabel(match.utcDate),
                        style: TextStyle(
                          color: Colors.red.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.red.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            MatchCard(match: match, onTap: () => widget.onMatchTap(match)),
          ],
        );
      },
    );
  }
}
