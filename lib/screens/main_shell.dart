// =============================================
// screens/main_shell.dart
// Bottom navigation shell:
//   Normal mode  (4 tabs): Takvim | Egzersiz | Sosyal | Profil
//   Hamile mode  (5 tabs): Takvim | Büyüme Bahçem | Egzersiz | Sosyal | Profil
// =============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_background.dart';
import '../l10n/app_localizations.dart';
import '../models/notification_prefs.dart';
import '../models/period_log.dart';
import '../models/reminder_plan.dart';
import '../providers/auth_provider.dart';
import '../providers/cycle_provider.dart';
import '../services/app_update_service.dart';
import '../services/reminder_notification_service.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUpdateService.instance.checkForUpdate(onDownloaded: _showRestartPrompt);
    });
  }

  /// Arka planda indirilen güncelleme hazır olunca gösterilir.
  void _showRestartPrompt() {
    if (!mounted) return;
    final isTr = AppLocalizations.of(context)!.isTurkish;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isTr
            ? 'Ayzit\'in yeni sürümü hazır 💕'
            : 'A new version of Ayzit is ready 💕'),
        duration: const Duration(minutes: 10),
        action: SnackBarAction(
          label: isTr ? 'Yeniden başlat' : 'Restart',
          onPressed: AppUpdateService.instance.installDownloadedUpdate,
        ),
      ),
    );
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

  /// Ayarlardaki regl / egzersiz / su hatırlatmalarını telefonda kurar.
  /// Tercihler, regl kayıtları, dil ya da gün değişince yeniden planlanır.
  void _syncReminders(CycleProvider cycle, NotificationPrefs prefs, bool isTr) {
    // Hamile takipte regl hatırlatmaları anlamsız; yalnızca diğerleri kalır.
    if (cycle.appMode == AppMode.hamileTakip) {
      prefs = prefs.copyWith(periodStart: false, periodEnd: false);
    }
    final now = DateTime.now();
    final activeStart = cycle.activePeriodStart;
    final signature = [
      prefs.toMap().toString(),
      cycle.periodLog.sortedKeys.join(','),
      cycle.cycleLength,
      cycle.periodLength,
      activeStart?.toIso8601String(),
      isTr,
      PeriodLog.keyOf(now),
    ].join('|');
    final plan = ReminderPlanner.plan(
      prefs: prefs,
      log: cycle.periodLog,
      cycleLength: cycle.cycleLength,
      periodLength: cycle.periodLength,
      activePeriodStart: activeStart,
      now: now,
      isTurkish: isTr,
    );
    ReminderNotificationService.instance.sync(plan, signature);
  }

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();
    final prefs = context.watch<AuthProvider>().appUser?.preferences.notifications;
    if (prefs != null) {
      final isTr = AppLocalizations.of(context)!.isTurkish;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncReminders(cycle, prefs, isTr);
      });
    }
    final isPregnancy = cycle.appMode == AppMode.hamileTakip;

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
