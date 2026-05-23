import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/utils/firestore_paths.dart';
import '../models/appointment.dart';
import '../services/appointment_notification_service.dart';

class AppointmentProvider extends ChangeNotifier {
  AppointmentProvider({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance {
    _authSub = _auth.authStateChanges().listen(_handleAuthChange);
    final current = _auth.currentUser;
    if (current != null) _handleAuthChange(current);
  }

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  String? _uid;

  List<Appointment> _appointments = const [];
  List<Appointment> get appointments => List.unmodifiable(_appointments);

  /// Bugün ve sonrası için randevular, tarihe göre artan.
  List<Appointment> get upcoming {
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month, now.day);
    final list = _appointments
        .where((a) => !a.dateTime.isBefore(cutoff))
        .toList()
      ..sort((x, y) => x.dateTime.compareTo(y.dateTime));
    return list;
  }

  List<Appointment> appointmentsForDay(DateTime day) {
    return _appointments
        .where((a) =>
            a.dateTime.year == day.year &&
            a.dateTime.month == day.month &&
            a.dateTime.day == day.day)
        .toList();
  }

  bool hasAppointmentOn(DateTime day) =>
      _appointments.any((a) =>
          a.dateTime.year == day.year &&
          a.dateTime.month == day.month &&
          a.dateTime.day == day.day);

  // ── Auth ──
  void _handleAuthChange(User? user) {
    _sub?.cancel();
    _sub = null;
    if (user == null || !user.emailVerified) {
      _uid = null;
      _appointments = const [];
      notifyListeners();
      return;
    }
    _uid = user.uid;
    _subscribe(user.uid);
  }

  CollectionReference<Map<String, dynamic>> _col(String uid) => _firestore
      .collection(FirestorePaths.users)
      .doc(uid)
      .collection(FirestorePaths.appointments);

  void _subscribe(String uid) {
    _sub = _col(uid).orderBy('dateTime').snapshots().listen((snap) {
      _appointments = snap.docs
          .map((d) => Appointment.fromDoc(d.id, d.data()))
          .toList();
      notifyListeners();
      // Gelecekteki randevuların bildirimlerini (yeniden) planla — idempotent.
      for (final a in _appointments) {
        if (!a.isPast) {
          AppointmentNotificationService.instance.scheduleForAppointment(a);
        }
      }
    });
  }

  // ── Yazma işlemleri ──
  Future<void> addAppointment({
    required String title,
    required DateTime dateTime,
    String note = '',
  }) async {
    final uid = _uid;
    if (uid == null) return;
    final temp = Appointment(
      id: 'tmp',
      title: title,
      dateTime: dateTime,
      note: note,
    );
    final ref = await _col(uid).add(temp.toMap());
    final created =
        Appointment(id: ref.id, title: title, dateTime: dateTime, note: note);
    // Hatırlatmaları planla + anında onay bildirimi göster.
    final svc = AppointmentNotificationService.instance;
    await svc.scheduleForAppointment(created);
    await svc.showAddedConfirmation(created);
  }

  Future<void> deleteAppointment(Appointment a) async {
    final uid = _uid;
    if (uid == null) return;
    await AppointmentNotificationService.instance.cancelForAppointment(a);
    await _col(uid).doc(a.id).delete();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _sub?.cancel();
    super.dispose();
  }
}
