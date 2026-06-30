// =============================================
// services/profanity_service.dart
// Loads the profanity word list from config/profanityList and caches it
// in memory. Falls back to a baked-in base list if the doc is missing.
// =============================================

import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/utils/firestore_paths.dart';

class ProfanityService {
  ProfanityService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  List<String>? _cached;
  Future<List<String>>? _inflight;

  static const List<String> _baseList = [
    // Turkish (normalized forms — matched case-insensitively & accent-insensitively)
    'amk', 'aq', 'amina', 'ananı', 'ananin', 'ananizin', 'bok', 'boklu',
    'göt', 'gotun', 'gotveren', 'götveren', 'ibne', 'orospu', 'oruspu',
    'puşt', 'pust', 'piç', 'pic', 'siktir', 'siktirgit', 'siktirbe',
    'yarrak', 'yarak', 'sik', 'sikim', 'sikik', 'sikerim', 'kahpe',
    'kancik', 'kancık', 'sürtük', 'surtuk', 'mal', 'gerizekali',
    'gerizekalı', 'dalyarak', 'dallama',
    // English
    'fuck', 'fucking', 'fuk', 'fuc', 'shit', 'bitch', 'bitches', 'cunt',
    'asshole', 'bastard', 'dick', 'pussy', 'slut', 'whore', 'motherfucker',
    'nigger', 'nigga', 'faggot', 'fag', 'retard', 'twat', 'wanker',
    'bollocks', 'bugger', 'prick', 'arse',
  ];

  Future<List<String>> loadList({bool forceRefresh = false}) async {
    if (!forceRefresh && _cached != null) return _cached!;
    if (_inflight != null) return _inflight!;

    final future = () async {
      try {
        final snap = await _firestore
            .collection(FirestorePaths.config)
            .doc(FirestorePaths.configProfanity)
            .get();
        final data = snap.data();
        final List<String> list = (data?['words'] as List?)
                ?.cast<String>()
                .where((e) => e.trim().isNotEmpty)
                .toList() ??
            const [];
        final merged = <String>{..._baseList, ...list}.toList();
        _cached = merged;
        return merged;
      } catch (_) {
        _cached = List<String>.from(_baseList);
        return _cached!;
      }
    }();

    _inflight = future;
    try {
      return await future;
    } finally {
      _inflight = null;
    }
  }

  /// Exposes the baked-in base list (so tools can seed the Firestore doc).
  static List<String> get baseList => List<String>.unmodifiable(_baseList);
}
