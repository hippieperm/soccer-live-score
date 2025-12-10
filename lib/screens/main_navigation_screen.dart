import 'package:flutter/material.dart';
import 'package:soccer/screens/home_screen.dart';
import 'package:soccer/screens/finished_matches_screen.dart';
import 'package:soccer/widgets/liquid_glass_bottom_nav.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const FinishedMatchesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_currentIndex],
          // 바텀 네비게이션 바를 하단에 고정
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: LiquidGlassBottomNav(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
