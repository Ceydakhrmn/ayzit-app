import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('tr');
  Locale get locale => _locale;
  bool get isTurkish => _locale.languageCode == 'tr';

  LanguageProvider() { _load(); }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final lang = doc.data()?['language'] as String?;
      if (lang != null) { _locale = Locale(lang); notifyListeners(); }
    } catch (_) {}
  }

  Future<void> setLocale(String code) async {
    _locale = Locale(code);
    notifyListeners();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({'language': code}, SetOptions(merge: true));
    } catch (_) {}
  }
}
