// =============================================
// screens/main_shell.dart
// 4-tab bottom navigation shell (shown when user is authenticated):
//   0 — Calendar (HomeScreen) — or PregnancyTreeScreen when appMode == hamileTakip
//   1 — Exercise (ExerciseScreen)
//   2 — Social
//   3 — Profile
// =============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_background.dart';
import '../providers/cycle_provider.dart';
import 'exercise_screen.dart';
import 'home_screen.dart';
import 'pregnancy/pregnancy_tree_screen.dart';
import 'profile/profile_screen.dart';
import 'social/social_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTap(int i) {
    setState(() => _index = i);
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the app mode so tab 0 swaps between the calendar and the
    // pregnancy tree screen automatically when the user changes mode.
    final appMode = context.select<CycleProvider, AppMode>((p) => p.appMode);
    final Widget firstTab = appMode == AppMode.hamileTakip
        ? const PregnancyTreeScreen()
        : const HomeScreen();

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: false,
        body: PageView(
        controller: _pageController,
        physics: const ClampingScrollPhysics(),
        onPageChanged: (i) => setState(() => _index = i),
        children: [
          firstTab,
          const ExerciseScreen(),
          const SocialScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement_outlined),
            activeIcon: Icon(Icons.self_improvement),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum_outlined),
            activeIcon: Icon(Icons.forum),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
      ),
    );
  }
}
