// =============================================
// services/activity_service.dart
// Paylaşıma gelen yorum / beğeni kayıtları (zil listesi).
// Kayıtları yorumu / beğeniyi yapan kişinin uygulaması yazar
// (CommentService, PostService.toggleLike); burada yalnızca sahibi okur
// ve okundu işaretler.
// =============================================

import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/utils/firestore_paths.dart';
import '../models/activity_item.dart';

class ActivityService {
  ActivityService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Listede gösterilen en fazla kayıt.
  static const int pageSize = 50;

  CollectionReference<Map<String, dynamic>> _col(String uid) => _firestore
      .collection(FirestorePaths.users)
      .doc(uid)
      .collection(FirestorePaths.activity);

  /// En yeni kayıtlar (yeniden eskiye).
  Stream<List<ActivityItem>> stream(String uid) => _col(uid)
      .orderBy(FirestorePaths.fCreatedAt, descending: true)
      .limit(pageSize)
      .snapshots()
      .map((s) => s.docs.map(ActivityItem.fromDoc).toList());

  Future<void> markAllRead(String uid, Iterable<ActivityItem> items) async {
    final unread = items.where((a) => !a.read).toList();
    if (unread.isEmpty) return;
    final batch = _firestore.batch();
    for (final a in unread) {
      batch.update(_col(uid).doc(a.id), {'read': true});
    }
    await batch.commit();
  }
}
