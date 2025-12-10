import 'package:flutter/material.dart';
import 'package:soccer/models/match_model.dart';
import 'package:soccer/models/score_model.dart';
import 'dart:ui';

class MatchCard extends StatelessWidget {
  final Match match;
  final VoidCallback onTap;

  const MatchCard({super.key, required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLive = match.isLive;
    final score = match.fullTime ?? match.score;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // 상태 및 날짜 정보
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // 날짜 (중앙)
                      Text(
                        _formatDate(match.utcDate),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // LIVE 표시 (왼쪽)
                      if (isLive)
                        Positioned(
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 홈 팀과 원정 팀 가로 배치
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 홈 팀
                      Expanded(
                        child: _buildTeamWithBlur(
                          team: match.homeTeam,
                          isHome: true,
                          score: score,
                        ),
                      ),
                      // 스코어 또는 VS
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: score != null
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${score.home ?? '-'}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      ':',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${score.away ?? '-'}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'VS',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      // 원정 팀
                      Expanded(
                        child: _buildTeamWithBlur(
                          team: match.awayTeam,
                          isHome: false,
                          score: score,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color? _getTeamBlurColor(Score? score, bool isHome) {
    if (score == null || score.home == null || score.away == null) {
      return null; // 스코어가 없으면 기본 색상
    }

    final homeScore = score.home!;
    final awayScore = score.away!;

    if (homeScore > awayScore) {
      // 홈팀 승리
      return isHome ? Colors.green : Colors.red;
    } else if (homeScore < awayScore) {
      // 원정팀 승리
      return isHome ? Colors.red : Colors.green;
    } else {
      // 무승부
      return Colors.grey;
    }
  }

  Widget _buildTeamWithBlur({
    required dynamic team,
    required bool isHome,
    Score? score,
  }) {
    final blurColor = _getTeamBlurColor(score, isHome);
    final isAway = !isHome;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          // 배경 블러 효과
          if (blurColor != null)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: blurColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          // 팀 정보
          Padding(
            padding: const EdgeInsets.all(8),
            child: _buildTeamColumn(team: team, isAway: isAway),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamColumn({required dynamic team, bool isAway = false}) {
    return Column(
      crossAxisAlignment: isAway
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        // 팀 로고
        Row(
          mainAxisAlignment: isAway
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (team.crest != null)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    team.crest!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.white.withOpacity(0.1),
                        child: const Icon(
                          Icons.sports_soccer,
                          color: Colors.white,
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
              )
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.sports_soccer,
                  color: Colors.white,
                  size: 24,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // 팀 이름
        Text(
          team.shortName ?? team.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: isAway ? TextAlign.right : TextAlign.left,
        ),
      ],
    );
  }

  String _formatDate(DateTime utcDate) {
    // UTC를 한국 시간(UTC+9)으로 변환
    final koreaDate = utcDate.add(const Duration(hours: 9));
    final now = DateTime.now().toUtc().add(const Duration(hours: 9));
    final today = DateTime(now.year, now.month, now.day);
    final matchDate = DateTime(koreaDate.year, koreaDate.month, koreaDate.day);

    if (matchDate == today) {
      return '오늘 - ${koreaDate.hour.toString().padLeft(2, '0')}:${koreaDate.minute.toString().padLeft(2, '0')}';
    } else if (matchDate == today.add(const Duration(days: 1))) {
      return '내일 - ${koreaDate.hour.toString().padLeft(2, '0')}:${koreaDate.minute.toString().padLeft(2, '0')}';
    } else {
      return '${koreaDate.month}/${koreaDate.day} - ${koreaDate.hour.toString().padLeft(2, '0')}:${koreaDate.minute.toString().padLeft(2, '0')}';
    }
  }
}
