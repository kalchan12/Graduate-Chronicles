import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../yearbook/explore_yearbook_screen.dart';
import '../community/community_home_screen.dart';
import '../portfolio/portfolio_hub_screen.dart';
import '../profile/profile_screen.dart';

/*
  Bottom Navigation Scaffold.

  The main shell of the application after login.
  Features:
  - Persistent bottom navigation bar.
  - Manages main screens: Home, Yearbook, Community, Portfolio, Profile.
  - LAZY LOADING: Only builds a tab's widget when the user first visits it.
    This prevents ~4 extra Supabase requests at login from tabs the user hasn't opened.
  - Preserves state of visited tabs using IndexedStack.
*/
class BottomNavigationScaffold extends StatefulWidget {
  const BottomNavigationScaffold({super.key});

  @override
  State<BottomNavigationScaffold> createState() =>
      _BottomNavigationScaffoldState();
}

class _BottomNavigationScaffoldState extends State<BottomNavigationScaffold> {
  int _currentIndex = 0;

  /// Track which tabs have been visited. Only visited tabs are built.
  /// Tab 0 (Home) is always visited by default.
  final Set<int> _visitedTabs = {0};

  static const _pageBuilders = [
    HomeScreen(),
    ExploreYearbookScreen(),
    CommunityHomeScreen(),
    PortfolioHubScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(_pageBuilders.length, (i) {
          // Only build the widget if the tab has been visited
          if (_visitedTabs.contains(i)) {
            return _pageBuilders[i];
          }
          // Unvisited tabs get a lightweight placeholder
          return const SizedBox.shrink();
        }),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() {
            _visitedTabs.add(i); // Mark as visited on first tap
            _currentIndex = i;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1B0423),
        selectedItemColor: const Color(0xFFE94CFF),
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories),
            label: 'Yearbook',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Community'),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            label: 'Portfolio',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
