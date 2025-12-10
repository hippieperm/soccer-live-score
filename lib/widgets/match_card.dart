import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soccer/models/match_model.dart';

class MatchCard extends StatelessWidget {
  final Match match;

  const MatchCard({super.key, required this.match});

  Widget _teamLogo(String crestUrl) {
    if (crestUrl.endsWith('.svg')) {
      return SvgPicture.network(
        crestUrl,
        height: 35,
        placeholderBuilder: (context) => const CircularProgressIndicator(),
      );
    } else {
      return Image.network(
        crestUrl,
        height: 35,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _formatStatus(match.status),
              style: TextStyle(
                color: match.status == 'LIVE' || match.status == 'IN_PLAY'
                    ? Colors.red
                    : match.status == 'SCHEDULED'
                    ? Colors.blue
                    : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTeamDisplay(match.homeTeam),
                _buildScoreDisplay(),
                _buildTeamDisplay(match.awayTeam),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamDisplay(dynamic team) {
    return Expanded(
      child: Column(
        children: [
          _teamLogo(team.crest),
          const SizedBox(height: 8),
          Text(
            team.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay() {
    // 경기 전 경기는 시간 표시, 그 외는 스코어 표시
    if (match.status == 'SCHEDULED') {
      final time = match.utcDate;
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return Text(
        '$hour:$minute',
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      );
    }

    final homeScore =
        match.score.fullTime?.home ?? match.score.halfTime?.home ?? 0;
    final awayScore =
        match.score.fullTime?.away ?? match.score.halfTime?.away ?? 0;

    return Text(
      '$homeScore - $awayScore',
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'IN_PLAY':
        return 'LIVE';
      case 'PAUSED':
        return 'Half Time';
      case 'FINISHED':
        return 'Finished';
      case 'SCHEDULED':
        return '경기 예정';
      default:
        return status;
    }
  }
}
