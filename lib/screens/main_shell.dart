// =============================================
// screens/main_shell.dart
// Bottom navigation shell:
//   Normal mode  (4 tabs): Takvim | Egzersiz | Sosyal | Profil
//   Hamile mode  (5 tabs): Takvim | Büyüme Bahçem | Egzersiz | Sosyal | Profil
// =============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_background.dart';
import '../providers/cycle_provider.dart';
import 'exercise_screen.dart';
import 'home_screen.dart';
import 'pregnancy/garden_screen.dart';
import 'profile/profile_screen.dart';
import 'social/social_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  bool? _prevIsPregnancy;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
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

  List<Widget> _pages(bool isPregnancy) => isPregnancy
      ? [
          const HomeScreen(),
          const GardenScreen(),
          const ExerciseScreen(),
          const SocialScreen(),
          const ProfileScreen(),
        ]
      : [
          const HomeScreen(),
          const ExerciseScreen(),
          const SocialScreen(),
          const ProfileScreen(),
        ];

  List<BottomNavigationBarItem> _navItems(bool isPregnancy) => [
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          activeIcon: Icon(Icons.calendar_month),
          label: '',
        ),
        if (isPregnancy)
          const BottomNavigationBarItem(
            icon: Icon(Icons.yard_outlined),
            activeIcon: Icon(Icons.yard),
            label: '',
          ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.self_improvement_outlined),
          activeIcon: Icon(Icons.self_improvement),
          label: '',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.forum_outlined),
          activeIcon: Icon(Icons.forum),
          label: '',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: '',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final isPregnancy =
        context.watch<CycleProvider>().appMode == AppMode.hamileTakip;

    // Mod değişince index'i sıfırla ve PageController'ı yenile.
    if (_prevIsPregnancy != null && _prevIsPregnancy != isPregnancy) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final old = _pageController;
        setState(() {
          _index = 0;
          _pageController = PageController();
        });
        old.dispose();
      });
    }
    _prevIsPregnancy = isPregnancy;

    final maxIndex = isPregnancy ? 4 : 3;
    final safeIndex = _index.clamp(0, maxIndex);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: false,
        body: PageView(
          controller: _pageController,
          physics: const ClampingScrollPhysics(),
          onPageChanged: (i) => setState(() => _index = i),
          children: _pages(isPregnancy),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: safeIndex,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: _onTap,
          items: _navItems(isPregnancy),
        ),
      ),
    );
  }
}
