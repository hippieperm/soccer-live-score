import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:soccer/services/api_service.dart';
import 'package:soccer/widgets/match_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      MatchList(futureMatches: apiService.getLiveAndScheduledMatches()),
      MatchList(futureMatches: apiService.getFinishedMatches()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Soccer Scores')),
      body: Stack(
        children: [
          // 배경 콘텐츠 (리퀴드 글라스 효과가 이 배경을 굴절시킵니다)
          if (_screens.isNotEmpty && _currentIndex < _screens.length)
            _screens[_currentIndex],

          // 리퀴드 글라스 레이어 (바텀 네비게이션 바)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: LiquidGlassLayer(
              settings: const LiquidGlassSettings(
                thickness: 20,
                glassColor: Color(0x33FFFFFF),
                lightIntensity: 1.5,
                saturation: 1.2,
                blur: 1,
                refractiveIndex: 1.3,
              ),
              child: SafeArea(
                top: false,
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: kBottomNavigationBarHeight,
                  ),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: LiquidGlass(
                    shape: const LiquidRoundedSuperellipse(borderRadius: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: BottomNavigationBar(
                        currentIndex: _currentIndex,
                        onTap: (index) {
                          if (index >= 0 && index < _screens.length) {
                            setState(() {
                              _currentIndex = index;
                            });
                          }
                        },
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        selectedItemColor: Colors.white,
                        unselectedItemColor: Colors.grey.withOpacity(0.7),
                        type: BottomNavigationBarType.fixed,
                        items: const [
                          BottomNavigationBarItem(
                            icon: Icon(Icons.live_tv),
                            label: 'Live',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.check_circle),
                            label: 'Finished',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
