import 'package:flutter/material.dart';
import 'package:soccer/models/match_model.dart';
import 'package:soccer/widgets/match_card.dart';

class MatchList extends StatelessWidget {
  final Future<List<Match>> futureMatches;

  const MatchList({super.key, required this.futureMatches});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Match>>(
      future: futureMatches,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Failed to load matches. Please check your internet connection and API key.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[700], fontSize: 16),
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No matches found for this category.'),
          );
        } else {
          final matches = snapshot.data!;
          // 라이브 경기를 먼저, 그 다음 시간순으로 정렬
          matches.sort((a, b) {
            final aIsLive = a.status == 'LIVE' || a.status == 'IN_PLAY';
            final bIsLive = b.status == 'LIVE' || b.status == 'IN_PLAY';

            if (aIsLive && !bIsLive) return -1;
            if (!aIsLive && bIsLive) return 1;

            // 둘 다 라이브이거나 둘 다 아니면 시간순 정렬
            return a.utcDate.compareTo(b.utcDate);
          });
          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              return MatchCard(match: matches[index]);
            },
          );
        }
      },
    );
  }
}
