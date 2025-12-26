import 'package:flutter/material.dart';
import '../../core/providers.dart';
import '../home/home_screen.dart';
import '../yearbook/explore_yearbook_screen.dart';
import '../message/message_screen.dart';
import '../portfolio/portfolio_select_screen.dart';
import '../profile/profile_screen.dart';

// Bottom navigation scaffold driven by Riverpod's `currentIndexProvider`.
// Bottom navigation implemented as a local StatefulWidget to keep tab state
// without relying on a provider for the index. This keeps tabs persistent
// using an IndexedStack while remaining UI-first.
class BottomNavigationScaffold extends StatefulWidget {
  const BottomNavigationScaffold({Key? key}) : super(key: key);

  @override
  State<BottomNavigationScaffold> createState() => _BottomNavigationScaffoldState();
}

class _BottomNavigationScaffoldState extends State<BottomNavigationScaffold> {
  int _currentIndex = 0;

  static const _pages = [HomeScreen(), ExploreYearbookScreen(), MessageScreen(), PortfolioSelectScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1B0423),
        selectedItemColor: const Color(0xFFE94CFF),
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_stories), label: 'Yearbook'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'Portfolio'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      // Show the floating add button only on the Home tab (index 0).
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {},
              backgroundColor: const Color(0xFF9B2CFF),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
