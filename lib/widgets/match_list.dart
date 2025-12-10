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
          return const Center(child: Text('No matches found for this category.'));
        } else {
          final matches = snapshot.data!;
          // Sort matches by date, newest first
          matches.sort((a, b) => b.utcDate.compareTo(a.utcDate));
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
