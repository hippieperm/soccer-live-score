import 'package:flutter/material.dart';
import 'package:soccer/models/match_model.dart';
import 'package:soccer/widgets/match_card.dart';

class MatchList extends StatelessWidget {
  final List<Match> matches;
  final Function(Match) onMatchTap;
  final bool isLoading;

  const MatchList({
    super.key,
    required this.matches,
    required this.onMatchTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (matches.isEmpty) {
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
      padding: const EdgeInsets.only(top: 8, bottom: 120),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        return MatchCard(
          match: matches[index],
          onTap: () => onMatchTap(matches[index]),
        );
      },
    );
  }
}
