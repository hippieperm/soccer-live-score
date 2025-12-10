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
                color: match.status == 'LIVE' ? Colors.red : Colors.grey,
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
    final homeScore = match.score.fullTime?.home ?? match.score.halfTime?.home ?? 0;
    final awayScore = match.score.fullTime?.away ?? match.score.halfTime?.away ?? 0;

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
        return 'Scheduled';
      default:
        return status;
    }
  }
}
