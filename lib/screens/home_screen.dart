import 'package:flutter/material.dart';
import 'package:soccer/services/api_service.dart';
import 'package:soccer/widgets/match_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Soccer Scores'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Live'),
              Tab(text: 'Finished'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MatchList(futureMatches: apiService.getLiveMatches()),
            MatchList(futureMatches: apiService.getFinishedMatches()),
          ],
        ),
      ),
    );
  }
}
