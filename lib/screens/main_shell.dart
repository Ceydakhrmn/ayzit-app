// =============================================
// screens/main_shell.dart
// Bottom navigation shell:
//   Normal mode  (4 tabs): Takvim | Egzersiz | Sosyal | Profil
//   Hamile mode  (5 tabs): Takvim | Büyüme Bahçem | Egzersiz | Sosyal | Profil
// =============================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_background.dart';
import '../l10n/app_localizations.dart';
import '../models/activity_item.dart';
import '../models/notification_prefs.dart';
import '../models/period_log.dart';
import '../models/reminder_plan.dart';
import '../providers/auth_provider.dart';
import '../providers/cycle_provider.dart';
import '../services/activity_service.dart';
import '../services/app_update_service.dart';
import '../services/reminder_notification_service.dart';
import 'exercise_screen.dart';
import 'home_screen.dart';
import 'pregnancy/garden_screen.dart';
import 'profile/profile_screen.dart';
import 'social/activity_screen.dart';
import 'social/social_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _index = 0;
  bool? _prevIsPregnancy;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  /// Uygulama arka plandan dönünce de güncelleme kontrol edilir; aksi halde
  /// yalnızca tamamen kapatılıp açıldığında kontrol ediliyordu.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkForUpdate();
  }

  void _checkForUpdate() =>
      AppUpdateService.instance.checkForUpdate(onDownloaded: _showRestartPrompt);

  // ── Yorum / beğeni (zil) ──
  StreamSubscription<List<ActivityItem>>? _activitySub;
  String? _activityUid;
  int _unreadActivity = 0;
  bool _commentAlerts = true;
  // İlk yüklemede eskiler için uyarı çıkmasın: görülen kayıtlar.
  Set<String>? _seenActivityIds;

  void _listenActivity(String? uid) {
    if (uid == _activityUid) return;
    _activityUid = uid;
    _activitySub?.cancel();
    _activitySub = null;
    _seenActivityIds = null;
    _unreadActivity = 0;
    if (uid == null) return;
    _activitySub = ActivityService().stream(uid).listen((items) {
      if (!mounted) return;
      final seen = _seenActivityIds;
      final fresh = seen == null
          ? const <ActivityItem>[]
          : items.where((a) => !a.read && !seen.contains(a.id)).toList();
      _seenActivityIds = items.map((a) => a.id).toSet();
      setState(() => _unreadActivity = items.where((a) => !a.read).length);
      if (fresh.isNotEmpty && _commentAlerts) _showActivityAlert(fresh);
    }, onError: (Object e) => debugPrint('MainShell.activity: $e'));
  }

  /// Uygulama açıkken gelen yeni yorum / beğeni için kısa uyarı.
  void _showActivityAlert(List<ActivityItem> fresh) {
    final isTr = AppLocalizations.of(context)!.isTurkish;
    final a = fresh.first;
    final isComment = a.type == ActivityType.comment;
    final more = fresh.length > 1 ? ' (+${fresh.length - 1})' : '';
    final text = isComment
        ? (isTr
            ? '💬 ${a.actorUsername} paylaşımına yorum yaptı$more'
            : '💬 ${a.actorUsername} commented on your post$more')
        : (isTr
            ? '💜 ${a.actorUsername} paylaşımını beğendi$more'
            : '💜 ${a.actorUsername} liked your post$more');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: isTr ? 'Gör' : 'View',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ActivityScreen()),
          ),
        ),
      ),
    );
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
    WidgetsBinding.instance.removeObserver(this);
    _activitySub?.cancel();
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
        // Okunmamış yorum / beğeni varsa Sosyal'de kırmızı nokta.
        BottomNavigationBarItem(
          icon: Badge(
            isLabelVisible: _unreadActivity > 0,
            child: const Icon(Icons.forum_outlined),
          ),
          activeIcon: Badge(
            isLabelVisible: _unreadActivity > 0,
            child: const Icon(Icons.forum),
          ),
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
    final auth = context.watch<AuthProvider>();
    final prefs = auth.appUser?.preferences.notifications;
    _commentAlerts = prefs?.commentOnPost ?? true;
    _listenActivity(auth.firebaseUser?.uid);
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
