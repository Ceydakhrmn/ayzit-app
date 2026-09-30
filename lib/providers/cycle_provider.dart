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
//   users/{uid}                         → cycleData, periodDays, appMode, reminders
//   users/{uid}/cycleNotes/{yyyy-MM-dd} → notes
//   users/{uid}/cycleHistory/{autoId}   → legacy cycles (read-only, migrated
//                                         into periodDays on first edit)
//
// Regl günleri `periodDays` listesinde ('yyyy-MM-dd') tutulur ve takvimde
// olduğu gibi gösterilir; iki kayıt arasındaki döngü gerçek aralıkla
// hesaplanır. İleriye dönük tahminler ayarlardaki döngü / regl süresini
// kullanır. Hiç kaydı olmayan kullanıcıya tahmin gösterilmez.
// =============================================

import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/utils/firestore_paths.dart';
import '../core/utils/firestore_stream_error.dart';
import '../models/cycle_model.dart';
import '../models/period_log.dart';

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

  /// Son (henüz bitmemiş) döngü: [cycleDays] bugüne kadar geçen gün sayısı.
  final bool ongoing;

  const CycleRecord({
    required this.start,
    required this.periodDays,
    required this.cycleDays,
    this.ongoing = false,
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
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _moodsSub;
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
  // Bahçe: Firestore'da saklanan hafta ve son dokunma tarihi.
  int? _gardenWeek;
  DateTime? _lastGardenTapDate;
  bool _reminderPeriodStart = true;
  bool _reminderPeriodEnd = false;
  bool _reminderOvulation = false;
  bool _reminderFertile = false;
  final Map<String, String> _dayNotes = {};
  final Map<String, String> _dayMoods = {};
  // Eski sürümün kaydettiği döngüler; yalnızca periodDays'e taşımak için okunur.
  final List<CycleRecord> _cycleHistory = [];
  // İşaretlenmiş regl günleri ('yyyy-MM-dd'). Alan henüz yoksa (eski kullanıcı)
  // günler eski verilerden türetilir, ilk düzenlemede kalıcı olarak yazılır.
  final Set<String> _periodDayKeys = {};
  bool _hasPeriodDaysField = false;
  PeriodLog? _logCache;
  // Ana takvimde regl günlerini düzenleme modu: değişiklikler Kaydet'e kadar
  // yalnızca bu taslakta tutulur.
  bool _editingPeriodDays = false;
  final Set<String> _draftPeriodKeys = {};
  PeriodLog? _draftLogCache;

  // ── Getters (same public surface as before) ──
  DateTime get focusedMonth => _focusedMonth;
  DateTime? get selectedDay => _selectedDay;
  int get cycleLength => _cycleLength;
  int get periodLength => _periodLength;
  bool get isPeriodActive => _isPeriodActive;
  AppMode get appMode => _appMode;
  DateTime? get pregnancyStartDate => _pregnancyStartDate;

  /// Tahmini Doğum Tarihi (TDT) = SAT + 280 gün.
  DateTime? get estimatedDueDate {
    final lmp = _pregnancyStartDate;
    if (lmp == null) return null;
    return lmp.add(const Duration(days: 280));
  }

  /// Mevcut gebelik haftası (1..40). SAT girilmediyse 1 döner.
  int get pregnancyWeek {
    final lmp = _pregnancyStartDate;
    if (lmp == null) return 1;
    final days = DateTime.now().difference(lmp).inDays;
    if (days < 0) return 1;
    final week = (days ~/ 7) + 1;
    return week.clamp(1, 40);
  }

  /// Mevcut hafta içindeki gün (0–6).
  int get pregnancyDayInWeek {
    final lmp = _pregnancyStartDate;
    if (lmp == null) return 0;
    final days = DateTime.now().difference(lmp).inDays;
    return days < 0 ? 0 : days % 7;
  }

  /// Toplam geçen gün sayısı.
  int get pregnancyTotalDays {
    final lmp = _pregnancyStartDate;
    if (lmp == null) return 0;
    return DateTime.now().difference(lmp).inDays.clamp(0, 280);
  }

  /// 42. haftayı geçtiyse true — "Doğum gerçekleşti mi?" uyarısı gösterilmeli.
  bool get isPostTerm {
    final lmp = _pregnancyStartDate;
    if (lmp == null) return false;
    return DateTime.now().difference(lmp).inDays > 294; // 42 hafta
  }

  /// Trimester hesabı:
  ///   1. Trimester: 1–12. hafta
  ///   2. Trimester: 13–26. hafta
  ///   3. Trimester: 27–40. hafta
  int trimesterForWeek(int week) {
    if (week <= 12) return 1;
    if (week <= 26) return 2;
    return 3;
  }

  // ── Büyüme Bahçesi ────────────────────────────────────────────────────

  /// Bahçe'de gösterilen hafta. Firestore'dan gelmezse gerçek haftayı kullanır.
  int get gardenWeek => (_gardenWeek ?? pregnancyWeek).clamp(1, 40);

  /// Kullanıcı bu hafta bahçeye dokunabilir mi (7 gün bekleme).
  bool get canTapGarden {
    final last = _lastGardenTapDate;
    if (last == null) return true;
    return DateTime.now().difference(last).inDays >= 7;
  }

  /// Yeni dokunmaya kaç gün kaldı.
  int get gardenCooldownDays {
    final last = _lastGardenTapDate;
    if (last == null) return 0;
    final elapsed = DateTime.now().difference(last).inDays;
    return (7 - elapsed).clamp(0, 7);
  }

  /// Bahçeyi bir hafta ilerletir ve son dokunma tarihini kaydeder.
  Future<void> advanceGardenWeek() async {
    final next = (gardenWeek + 1).clamp(1, 40);
    _gardenWeek = next;
    _lastGardenTapDate = DateTime.now();
    notifyListeners();
    await _updateUserDoc({
      'pregnancy': {
        'gardenWeek': next,
        'lastGardenTap': Timestamp.fromDate(_lastGardenTapDate!),
      },
    });
  }

  bool get reminderPeriodStart => _reminderPeriodStart;
  bool get reminderPeriodEnd => _reminderPeriodEnd;
  bool get reminderOvulation => _reminderOvulation;
  bool get reminderFertile => _reminderFertile;
  String noteForDay(DateTime day) => _dayNotes[_dateKey(day)] ?? '';
  String moodForDay(DateTime day) => _dayMoods[_dateKey(day)] ?? '';
  /// Kayıtlı regl günleri ve bunlardan çıkan dönemler.
  PeriodLog get periodLog => _logCache ??= _hasPeriodDaysField
      ? PeriodLog.fromKeys(_periodDayKeys)
      : PeriodLog(_legacyPeriodDays());

  /// Kullanıcının hiç regl kaydı var mı? Yoksa takvimde tahmin gösterilmez.
  bool get hasPeriodRecords => !periodLog.isEmpty;

  /// Son kaydedilen reglin başlangıcı; hiç kayıt yoksa null.
  DateTime? get lastPeriodStart =>
      periodLog.isEmpty ? null : periodLog.spans.last.start;

  /// Son kayıtlı regl + ayarlardaki sürelerle sonraki regl, ovulasyon ve
  /// doğurganlık penceresi (takvim renkleriyle aynı hesap). Kayıt yoksa null.
  CycleForecast? get forecast => forecastCycle(
        log: periodLog,
        cycleLength: _cycleLength,
        periodLength: _periodLength,
        today: DateTime.now(),
      );

  /// Dönem kayıtlarından türetilen geçmiş (eskiden yeniye).
  List<CycleRecord> get cycleHistory {
    final spans = periodLog.spans;
    final today = PeriodLog.dateOnly(DateTime.now());
    return List.unmodifiable([
      for (var i = 0; i < spans.length; i++)
        CycleRecord(
          start: spans[i].start,
          periodDays: spans[i].length,
          cycleDays: i + 1 < spans.length
              ? PeriodLog.daysBetween(spans[i].start, spans[i + 1].start)
              : math.max(PeriodLog.daysBetween(spans[i].start, today) + 1,
                  spans[i].length),
          ongoing: i + 1 == spans.length,
        ),
    ]);
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ── Auth state handling ──
  void _handleAuthChange(User? user) {
    _userDocSub?.cancel();
    _notesSub?.cancel();
    _moodsSub?.cancel();
    _historySub?.cancel();
    _userDocSub = null;
    _notesSub = null;
    _moodsSub = null;
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
    _periodDayKeys.clear();
    _hasPeriodDaysField = false;
    _editingPeriodDays = false;
    _draftPeriodKeys.clear();
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

      final periodDays = data['periodDays'];
      _periodDayKeys.clear();
      _hasPeriodDaysField = periodDays is List;
      if (periodDays is List) {
        _periodDayKeys.addAll(periodDays.whereType<String>());
      }

      _appMode = _parseAppMode(data['appMode'] as String?);

      // Pregnancy LMP date + bahçe durumu
      final pregnancy = (data['pregnancy'] as Map<String, dynamic>?) ?? const {};
      _pregnancyStartDate =
          (pregnancy['startDate'] as Timestamp?)?.toDate();
      _gardenWeek = (pregnancy['gardenWeek'] as num?)?.toInt();
      _lastGardenTapDate =
          (pregnancy['lastGardenTap'] as Timestamp?)?.toDate();


      final reminders =
          (data['reminders'] as Map<String, dynamic>?) ?? const {};
      _reminderPeriodStart = reminders['periodStart'] as bool? ?? true;
      _reminderPeriodEnd = reminders['periodEnd'] as bool? ?? false;
      _reminderOvulation = reminders['ovulation'] as bool? ?? false;
      _reminderFertile = reminders['fertile'] as bool? ?? false;

      notifyListeners();
    }, onError: (Object e, StackTrace s) {
      handleFirestoreStreamError('CycleProvider.userDoc', e, s);
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
    }, onError: (Object e, StackTrace s) {
      handleFirestoreStreamError('CycleProvider.notes', e, s);
    });
  }

  void _subscribeMoods(String uid) {
    _moodsSub = _userRef(uid)
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
    }, onError: (Object e, StackTrace s) {
      handleFirestoreStreamError('CycleProvider.moods', e, s);
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
    }, onError: (Object e, StackTrace s) {
      handleFirestoreStreamError('CycleProvider.history', e, s);
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
  /// Regli [date] gününde başlatır. Seçim temizlenir ki daha sonra "Bitir"e
  /// basıldığında başlangıç günü yanlışlıkla bitiş günü sayılmasın.
  void startPeriod(DateTime date) {
    final day = PeriodLog.dateOnly(date);
    _periodActualStart = day;
    _cycleStart = day;
    _periodEndDate = null;
    _isPeriodActive = true;
    _selectedDay = null;
    _mutatePeriodDays((keys) => keys.add(PeriodLog.keyOf(day)));
  }

  /// Devam eden regli [endDate] gününde bitirir (verilmezse / gelecekteyse
  /// bugün). Yalnızca başlangıç ile bitiş arası işaretlenir; sonraki günler
  /// doldurulmaz. Bitiş başlangıçtan önceyse hiçbir şey yapmaz ve null döner;
  /// aksi halde kullanılan bitiş gününü döndürür.
  DateTime? endPeriod([DateTime? endDate]) {
    final start = PeriodLog.dateOnly(_periodActualStart ?? _cycleStart);
    final today = PeriodLog.dateOnly(DateTime.now());
    var end = PeriodLog.dateOnly(endDate ?? today);
    if (end.isAfter(today)) end = today;
    if (end.isBefore(start)) return null;

    _isPeriodActive = false;
    _selectedDay = null;
    _mutatePeriodDays((keys) {
      // Kaydetmeden önce atanmalı; kayıt _periodEndDate'i de yazar.
      _periodEndDate = PeriodLog.applyPeriodEnd(keys, start, end);
    });
    return _periodEndDate;
  }

  // ── Ana takvimde regl günlerini düzenleme ──
  bool get isEditingPeriodDays => _editingPeriodDays;

  bool get hasPeriodDraftChanges {
    final saved = periodLog.sortedKeys.toSet();
    return saved.length != _draftPeriodKeys.length ||
        !saved.containsAll(_draftPeriodKeys);
  }

  void beginPeriodDaysEdit() {
    _draftPeriodKeys
      ..clear()
      ..addAll(periodLog.sortedKeys);
    _editingPeriodDays = true;
    _selectedDay = null;
    notifyListeners();
  }

  /// Taslakta günü regl olarak işaretler / kaldırır. Gelecek günler yok sayılır.
  void togglePeriodDraftDay(DateTime day) {
    if (!_editingPeriodDays) return;
    final d = PeriodLog.dateOnly(day);
    if (d.isAfter(PeriodLog.dateOnly(DateTime.now()))) return;
    final key = PeriodLog.keyOf(d);
    if (!_draftPeriodKeys.remove(key)) _draftPeriodKeys.add(key);
    notifyListeners();
  }

  void cancelPeriodDaysEdit() {
    _editingPeriodDays = false;
    _draftPeriodKeys.clear();
    notifyListeners();
  }

  void savePeriodDaysEdit() {
    if (!_editingPeriodDays) return;
    final days = PeriodLog.fromKeys(_draftPeriodKeys).days;
    _editingPeriodDays = false;
    _draftPeriodKeys.clear();
    setPeriodDays(days);
  }

  /// Düzenleme modunda takvim rengi: yalnızca taslakta işaretli günler regl
  /// rengi alır (dönemin kaçıncı günü olduğuna göre); tahmin gösterilmez.
  DayPhase draftPhaseOf(DateTime date) {
    final log = _draftLogCache ??= PeriodLog.fromKeys(_draftPeriodKeys);
    if (!log.contains(date)) return DayPhase.none;
    final span = log.spanCovering(date)!;
    return CycleModel.periodPhaseFor(
        PeriodLog.daysBetween(span.start, date) + 1);
  }

  /// Regl günlerinin tamamını verilen günlerle değiştirip kaydeder.
  void setPeriodDays(Iterable<DateTime> days) {
    final log = PeriodLog(days);
    final keys = log.sortedKeys.toSet();
    // Devam eden reglin başlangıç günü kaldırıldıysa artık aktif değildir.
    final activeStart = _periodActualStart;
    if (_isPeriodActive &&
        activeStart != null &&
        !keys.contains(PeriodLog.keyOf(activeStart))) {
      _isPeriodActive = false;
    }
    if (!log.isEmpty) _cycleStart = log.spans.last.start;
    _hasPeriodDaysField = true;
    _periodDayKeys
      ..clear()
      ..addAll(keys);
    notifyListeners();
    _savePeriodDays();
  }

  /// Regl günlerini değiştirir; eski kullanıcının türetilmiş kayıtları önce
  /// kalıcı listeye taşınır ki hiçbir geçmiş dönem kaybolmasın.
  void _mutatePeriodDays(void Function(Set<String> keys) change) {
    if (!_hasPeriodDaysField) {
      final legacy = periodLog.sortedKeys;
      _periodDayKeys
        ..clear()
        ..addAll(legacy);
      _hasPeriodDaysField = true;
    }
    change(_periodDayKeys);
    notifyListeners();
    _savePeriodDays();
  }

  void _savePeriodDays() {
    _updateUserDoc({
      ..._currentCycleDataMap(),
      'periodDays': (_periodDayKeys.toList()..sort()),
    });
  }

  /// periodDays alanı olmayan (eski sürüm) kullanıcılar için regl günlerini
  /// eski döngü geçmişinden ve son başlatılan reglden türetir.
  List<DateTime> _legacyPeriodDays() {
    final days = <DateTime>[];
    void addRange(DateTime start, int length) {
      for (var i = 0; i < length; i++) {
        days.add(DateTime(start.year, start.month, start.day + i));
      }
    }

    for (final r in _cycleHistory) {
      addRange(PeriodLog.dateOnly(r.start), r.periodDays.clamp(1, 15));
    }
    final actualStart = _periodActualStart;
    if (actualStart != null) {
      final start = PeriodLog.dateOnly(actualStart);
      final int length;
      if (_isPeriodActive) {
        final today = PeriodLog.dateOnly(DateTime.now());
        length = PeriodLog.daysBetween(start, today) + 1;
      } else if (_periodEndDate != null) {
        length = PeriodLog.daysBetween(start, _periodEndDate!) + 1;
      } else {
        length = _periodLength;
      }
      addRange(start, length.clamp(1, 15));
    }
    return days;
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
  DayPhase phaseOf(DateTime date) => phaseForDay(
        date: date,
        log: periodLog,
        cycleLength: _cycleLength,
        periodLength: _periodLength,
        activePeriodStart: _isPeriodActive ? _periodActualStart : null,
      );

  // ── Statistics helpers ──
  /// Son [n] tamamlanmış döngünün gerçek uzunlukları (kayıt yoksa boş).
  List<int> lastCycleLengths({int n = 6}) {
    final lengths = periodLog.cycleLengths();
    return lengths.length <= n ? lengths : lengths.sublist(lengths.length - n);
  }

  /// Son [n] regl döneminin süreleri (devam eden regl hariç, kayıt yoksa boş).
  List<int> lastPeriodLengths({int n = 6}) {
    final activeStart = _isPeriodActive ? _periodActualStart : null;
    final lengths = [
      for (final s in periodLog.spans)
        if (activeStart == null || PeriodLog.daysBetween(s.start, activeStart) != 0)
          s.length,
    ];
    return lengths.length <= n ? lengths : lengths.sublist(lengths.length - n);
  }

  @override
  void notifyListeners() {
    // Her durum değişikliğinde regl kaydı önbellekleri yeniden hesaplanır.
    _logCache = null;
    _draftLogCache = null;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _userDocSub?.cancel();
    _notesSub?.cancel();
    _moodsSub?.cancel();
    _historySub?.cancel();
    super.dispose();
  }
}
