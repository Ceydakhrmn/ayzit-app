// =============================================
// providers/cycle_provider.dart
// Cycle + period + notes + settings state, backed by Firestore.
//
// Public API is preserved from the previous SharedPreferences version
// so existing screens and widgets (HomeScreen, SettingsScreen, widgets/
// *.dart) do not need changes.
//
// On auth state change: unsubscribes from old user's snapshots, resets
// local state, and (if signed in + verified) subscribes to the new
// user's Firestore docs:
//   users/{uid}                         → cycleData, appMode, reminders
//   users/{uid}/cycleNotes/{yyyy-MM-dd} → notes
//   users/{uid}/cycleHistory/{autoId}   → previous cycles
// =============================================

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/utils/firestore_paths.dart';
import '../models/cycle_model.dart';

enum AppMode { reglTakip, hamileTakip, hamilleKalma }

AppMode _parseAppMode(String? raw) {
  switch (raw) {
    case 'hamileTakip':
      return AppMode.hamileTakip;
    case 'hamilleKalma':
      return AppMode.hamilleKalma;
    case 'reglTakip':
    default:
      return AppMode.reglTakip;
  }
}

class CycleRecord {
  final DateTime start;
  final int periodDays;
  final int cycleDays;

  const CycleRecord({
    required this.start,
    required this.periodDays,
    required this.cycleDays,
  });

  Map<String, dynamic> toMap() => {
        'start': Timestamp.fromDate(start),
        'periodDays': periodDays,
        'cycleDays': cycleDays,
      };

  factory CycleRecord.fromMap(Map<String, dynamic> map) {
    return CycleRecord(
      start: (map['start'] as Timestamp?)?.toDate() ?? DateTime.now(),
      periodDays: (map['periodDays'] as num?)?.toInt() ?? 5,
      cycleDays: (map['cycleDays'] as num?)?.toInt() ?? 28,
    );
  }
}

class CycleProvider extends ChangeNotifier {
  CycleProvider({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month),
        _cycleStart =
            DateTime(DateTime.now().year, DateTime.now().month - 1, 18),
        _cycleLength = 28,
        _periodLength = 5 {
    _authSub = _auth.authStateChanges().listen(_handleAuthChange);
    // Handle the already-signed-in-at-cold-start case.
    final current = _auth.currentUser;
    if (current != null) _handleAuthChange(current);
  }

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _notesSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _historySub;

  String? _uid;

  // ── State ──
  DateTime _focusedMonth;
  DateTime? _selectedDay;
  DateTime _cycleStart;
  int _cycleLength;
  int _periodLength;
  bool _isPeriodActive = false;
  DateTime? _periodActualStart;
  DateTime? _periodEndDate;
  AppMode _appMode = AppMode.reglTakip;
  // Pregnancy: last menstrual period (LMP) - used to compute current pregnancy week
  DateTime? _pregnancyStartDate;
  bool _reminderPeriodStart = true;
  bool _reminderPeriodEnd = false;
  bool _reminderOvulation = false;
  bool _reminderFertile = false;
  final Map<String, String> _dayNotes = {};
  final Map<String, String> _dayMoods = {};
  final List<CycleRecord> _cycleHistory = [];

  // ── Getters (same public surface as before) ──
  DateTime get focusedMonth => _focusedMonth;
  DateTime? get selectedDay => _selectedDay;
  int get cycleLength => _cycleLength;
  int get periodLength => _periodLength;
  bool get isPeriodActive => _isPeriodActive;
  AppMode get appMode => _appMode;
  DateTime? get pregnancyStartDate => _pregnancyStartDate;

  /// Current pregnancy week (1..40) based on LMP date.
  /// Returns 1 if no LMP set or computed week < 1.
  int get pregnancyWeek {
    final lmp = _pregnancyStartDate;
    if (lmp == null) return 1;
    final days = DateTime.now().difference(lmp).inDays;
    final week = (days ~/ 7) + 1;
    if (week < 1) return 1;
    if (week > 40) return 40;
    return week;
  }

  /// Trimester for a given week:
  ///   1st: 1..12
  ///   2nd: 13..27
  ///   3rd: 28..40
  int trimesterForWeek(int week) {
    if (week <= 12) return 1;
    if (week <= 27) return 2;
    return 3;
  }

  bool get reminderPeriodStart => _reminderPeriodStart;
  bool get reminderPeriodEnd => _reminderPeriodEnd;
  bool get reminderOvulation => _reminderOvulation;
  bool get reminderFertile => _reminderFertile;
  String noteForDay(DateTime day) => _dayNotes[_dateKey(day)] ?? '';
  String moodForDay(DateTime day) => _dayMoods[_dateKey(day)] ?? '';
  List<CycleRecord> get cycleHistory => List.unmodifiable(_cycleHistory);

  CycleModel get cycle => CycleModel(
        cycleStart: _cycleStart,
        cycleLength: _cycleLength,
        periodLength: _periodLength,
      );

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ── Auth state handling ──
  void _handleAuthChange(User? user) {
    _userDocSub?.cancel();
    _notesSub?.cancel();
    _historySub?.cancel();
    _userDocSub = null;
    _notesSub = null;
    _historySub = null;

    if (user == null || !user.emailVerified) {
      _uid = null;
      _resetToDefaults();
      notifyListeners();
      return;
    }

    _uid = user.uid;
    _subscribeUserDoc(user.uid);
    _subscribeNotes(user.uid);
    _subscribeMoods(user.uid);
    _subscribeHistory(user.uid);
  }

  void _resetToDefaults() {
    _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _selectedDay = null;
    _cycleStart =
        DateTime(DateTime.now().year, DateTime.now().month - 1, 18);
    _cycleLength = 28;
    _periodLength = 5;
    _isPeriodActive = false;
    _periodActualStart = null;
    _periodEndDate = null;
    _appMode = AppMode.reglTakip;
    _reminderPeriodStart = true;
    _reminderPeriodEnd = false;
    _reminderOvulation = false;
    _reminderFertile = false;
    _dayNotes.clear();
    _dayMoods.clear();
    _cycleHistory.clear();
  }

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _firestore.collection(FirestorePaths.users).doc(uid);

  void _subscribeUserDoc(String uid) {
    _userDocSub = _userRef(uid).snapshots().listen((snap) {
      final data = snap.data();
      if (data == null) return;

      final cycle = (data['cycleData'] as Map<String, dynamic>?) ?? const {};
      _cycleStart = (cycle['cycleStart'] as Timestamp?)?.toDate() ?? _cycleStart;
      _cycleLength = (cycle['cycleLength'] as num?)?.toInt() ?? _cycleLength;
      _periodLength = (cycle['periodLength'] as num?)?.toInt() ?? _periodLength;
      _isPeriodActive = cycle['isPeriodActive'] as bool? ?? false;
      _periodActualStart = (cycle['periodActualStart'] as Timestamp?)?.toDate();
      _periodEndDate = (cycle['periodEndDate'] as Timestamp?)?.toDate();

      _appMode = _parseAppMode(data['appMode'] as String?);

      // Pregnancy LMP date
      final pregnancy = (data['pregnancy'] as Map<String, dynamic>?) ?? const {};
      _pregnancyStartDate =
          (pregnancy['startDate'] as Timestamp?)?.toDate();


      final reminders =
          (data['reminders'] as Map<String, dynamic>?) ?? const {};
      _reminderPeriodStart = reminders['periodStart'] as bool? ?? true;
      _reminderPeriodEnd = reminders['periodEnd'] as bool? ?? false;
      _reminderOvulation = reminders['ovulation'] as bool? ?? false;
      _reminderFertile = reminders['fertile'] as bool? ?? false;

      notifyListeners();
    });
  }

  void _subscribeNotes(String uid) {
    _notesSub = _userRef(uid)
        .collection(FirestorePaths.cycleNotes)
        .snapshots()
        .listen((snap) {
      _dayNotes.clear();
      for (final doc in snap.docs) {
        final note = doc.data()['note'] as String?;
        if (note != null && note.isNotEmpty) {
          _dayNotes[doc.id] = note;
        }
      }
      notifyListeners();
    });
  }

  void _subscribeMoods(String uid) {
    _userRef(uid)
        .collection(FirestorePaths.cycleMoods)
        .snapshots()
        .listen((snap) {
      _dayMoods.clear();
      for (final doc in snap.docs) {
        final mood = doc.data()['mood'] as String?;
        if (mood != null && mood.isNotEmpty) {
          _dayMoods[doc.id] = mood;
        }
      }
      notifyListeners();
    });
  }

  void _subscribeHistory(String uid) {
    _historySub = _userRef(uid)
        .collection(FirestorePaths.cycleHistory)
        .orderBy('start')
        .snapshots()
        .listen((snap) {
      _cycleHistory
        ..clear()
        ..addAll(snap.docs.map((d) => CycleRecord.fromMap(d.data())));
      // Retain only the last 12 locally, as before.
      if (_cycleHistory.length > 12) {
        _cycleHistory.removeRange(0, _cycleHistory.length - 12);
      }
      notifyListeners();
    });
  }

  // ── Writes (fire-and-forget; snapshot listener will re-sync) ──
  Future<void> _updateUserDoc(Map<String, dynamic> updates) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _userRef(uid).set(updates, SetOptions(merge: true));
    } catch (e) {
      debugPrint('CycleProvider._updateUserDoc error: $e');
    }
  }

  Map<String, dynamic> _currentCycleDataMap() => {
        'cycleData': {
          'cycleStart': Timestamp.fromDate(_cycleStart),
          'cycleLength': _cycleLength,
          'periodLength': _periodLength,
          'isPeriodActive': _isPeriodActive,
          if (_periodActualStart != null)
            'periodActualStart': Timestamp.fromDate(_periodActualStart!),
          if (_periodEndDate != null)
            'periodEndDate': Timestamp.fromDate(_periodEndDate!),
        },
      };

  // ── Navigation ──
  void previousMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    notifyListeners();
  }

  void nextMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    notifyListeners();
  }

  void selectDay(DateTime day) {
    _selectedDay = day;
    notifyListeners();
  }

  // ── Period start/end ──
  void startPeriod(DateTime date) {
    _periodActualStart = date;
    _cycleStart = date;
    _periodEndDate = null;
    _isPeriodActive = true;
    notifyListeners();
    _updateUserDoc(_currentCycleDataMap());
  }

  void endPeriod() {
    final now = DateTime.now();
    _periodEndDate = now;
    final startForCalc = _periodActualStart ?? _cycleStart;
    final actualDays = now.difference(startForCalc).inDays + 1;
    final newPeriodLen = actualDays.clamp(1, 15);
    _periodLength = ((_periodLength + newPeriodLen) / 2).round();

    final record = CycleRecord(
      start: _cycleStart,
      periodDays: newPeriodLen,
      cycleDays: _cycleLength,
    );
    _cycleHistory.add(record);
    if (_cycleHistory.length > 12) _cycleHistory.removeAt(0);

    _isPeriodActive = false;
    notifyListeners();

    _updateUserDoc(_currentCycleDataMap());
    final uid = _uid;
    if (uid != null) {
      _userRef(uid)
          .collection(FirestorePaths.cycleHistory)
          .add(record.toMap())
          .catchError((e) {
        debugPrint('cycleHistory add error: $e');
        // Needed because catchError must return a DocumentReference<Map<String,dynamic>>
        return _userRef(uid)
            .collection(FirestorePaths.cycleHistory)
            .doc();
      });
    }
  }

  // ── Cycle settings ──
  void updateCycleLength(int value) {
    _cycleLength = value;
    notifyListeners();
    _updateUserDoc(_currentCycleDataMap());
  }

  void updatePeriodLength(int value) {
    _periodLength = value;
    notifyListeners();
    _updateUserDoc(_currentCycleDataMap());
  }

  // ── App mode ──
  void updateAppMode(AppMode mode) {
    _appMode = mode;
    notifyListeners();
    _updateUserDoc({'appMode': mode.name});
  }

  // ── Pregnancy LMP date ──
  void updatePregnancyStartDate(DateTime date) {
    _pregnancyStartDate = date;
    notifyListeners();
    _updateUserDoc({
      'pregnancy': {
        'startDate': Timestamp.fromDate(date),
      },
    });
  }

  // ── Reminders ──
  void updateReminderPeriodStart(bool v) {
    _reminderPeriodStart = v;
    notifyListeners();
    _updateUserDoc({
      'reminders': {'periodStart': v},
    });
  }

  void updateReminderPeriodEnd(bool v) {
    _reminderPeriodEnd = v;
    notifyListeners();
    _updateUserDoc({
      'reminders': {'periodEnd': v},
    });
  }

  void updateReminderOvulation(bool v) {
    _reminderOvulation = v;
    notifyListeners();
    _updateUserDoc({
      'reminders': {'ovulation': v},
    });
  }

  void updateReminderFertile(bool v) {
    _reminderFertile = v;
    notifyListeners();
    _updateUserDoc({
      'reminders': {'fertile': v},
    });
  }

  // ── Daily moods ──
  void saveMood(DateTime day, String mood) {
    final key = _dateKey(day);
    if (mood.isEmpty) {
      _dayMoods.remove(key);
    } else {
      _dayMoods[key] = mood;
    }
    notifyListeners();

    final uid = _uid;
    if (uid == null) return;
    final ref = _userRef(uid).collection(FirestorePaths.cycleMoods).doc(key);
    if (mood.isEmpty) {
      ref.delete().catchError((e) => debugPrint('mood delete error: $e'));
    } else {
      ref.set({
        'mood': mood,
        'updatedAt': FieldValue.serverTimestamp(),
      }).catchError((e) => debugPrint('mood save error: $e'));
    }
  }

  // ── Daily notes ──
  void saveNote(DateTime day, String note) {
    final key = _dateKey(day);
    if (note.isEmpty) {
      _dayNotes.remove(key);
    } else {
      _dayNotes[key] = note;
    }
    notifyListeners();

    final uid = _uid;
    if (uid == null) return;
    final ref = _userRef(uid).collection(FirestorePaths.cycleNotes).doc(key);
    if (note.isEmpty) {
      ref.delete().catchError((e) => debugPrint('note delete error: $e'));
    } else {
      ref.set({
        'note': note,
        'updatedAt': FieldValue.serverTimestamp(),
      }).catchError((e) => debugPrint('note save error: $e'));
    }
  }

  // ── Phase lookup ──
  DayPhase phaseOf(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final actualStart = _periodActualStart;

    if (actualStart != null) {
      final start = DateTime(actualStart.year, actualStart.month, actualStart.day);

      if (_isPeriodActive) {
        // Regl aktif: başlangıçtan periodLength gün boyunca regl rengi
        final periodEnd = start.add(Duration(days: _periodLength - 1));

        if (!d.isBefore(start) && !d.isAfter(periodEnd)) {
          // Aktif regl günleri (tüm periodLength günü)
          final dayNum = d.difference(start).inDays + 1;
          if (dayNum <= 2) return DayPhase.periodPeak;
          if (dayNum <= 3) return DayPhase.periodMid;
          return DayPhase.periodLight;
        }

        // Regl bittikten sonraki günler: ovulasyon/doğurganlık göster
        // Bir sonraki döngü başlangıcını baz al (start + cycleLength)
        final nextCycleStart = start.add(Duration(days: _cycleLength));
        final model = CycleModel(
          cycleStart: nextCycleStart,
          cycleLength: _cycleLength,
          periodLength: _periodLength,
        );
        final dayInNextCycle = model.dayOfCycle(date);
        // Bir sonraki döngünün regl günlerini henüz gösterme
        if (dayInNextCycle <= _periodLength) return DayPhase.none;
        return model.phaseOf(date);
      } else {
        // Regl bitti: gerçek regl aralığını boya
        final endDate = _periodEndDate != null
            ? DateTime(_periodEndDate!.year, _periodEndDate!.month, _periodEndDate!.day)
            : start.add(Duration(days: _periodLength - 1));

        if (!d.isBefore(start) && !d.isAfter(endDate)) {
          final dayNum = d.difference(start).inDays + 1;
          if (dayNum <= 2) return DayPhase.periodPeak;
          if (dayNum <= 3) return DayPhase.periodMid;
          return DayPhase.periodLight;
        }

        // Regl bittikten sonra doğurganlık/ovulasyon: actualStart baz alarak hesapla
        // Regl günlerini (1..periodLength) tekrar renklendirme — zaten yukarıda renklendirildi.
        final model = CycleModel(
          cycleStart: start,
          cycleLength: _cycleLength,
          periodLength: _periodLength,
        );
        final phase = model.phaseOf(date);
        final dayInCycle = model.dayOfCycle(date);
        if (dayInCycle <= _periodLength) return DayPhase.none;
        return phase;
      }
    }

    // Hiç regl girilmemişse varsayılan hesap
    return cycle.phaseOf(date);
  }

  // ── Statistics helpers ──
  List<int> lastCycleLengths({int n = 6}) {
    final records = _cycleHistory.reversed.take(n).toList().reversed.toList();
    if (records.isEmpty) return List.filled(n, _cycleLength);
    return records.map((r) => r.cycleDays).toList();
  }

  List<int> lastPeriodLengths({int n = 6}) {
    final records = _cycleHistory.reversed.take(n).toList().reversed.toList();
    if (records.isEmpty) return List.filled(n, _periodLength);
    return records.map((r) => r.periodDays).toList();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _userDocSub?.cancel();
    _notesSub?.cancel();
    _historySub?.cancel();
    super.dispose();
  }
}
