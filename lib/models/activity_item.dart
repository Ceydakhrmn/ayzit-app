// =============================================
// models/activity_item.dart
// users/{ownerUid}/activity/{id} — paylaşım sahibine düşen yorum / beğeni
// kaydı. Yorumu ya da beğeniyi yapan kişinin uygulaması, aynı işlemin
// içinde yazar (bkz. firestore.rules). Uygulama içindeki zil listesini ve
// Google Apps Script'in gönderdiği bildirimleri besler.
//
// Kimlikler sabittir, böylece aynı beğeni iki kez kayıt üretmez ve geri
// alınınca / yorum silinince kayıt da silinebilir:
//   like_{postId}_{actorUid}   ·   comment_{commentId}
// =============================================

import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityType { comment, like }

class ActivityItem {
  final String id;
  final ActivityType type;
  final String actorId;
  final String actorUsername;
  final String postId;
  final String? commentId;
  final String? text;
  final DateTime createdAt;
  final bool read;

  const ActivityItem({
    required this.id,
    required this.type,
    required this.actorId,
    required this.actorUsername,
    required this.postId,
    this.commentId,
    this.text,
    required this.createdAt,
    this.read = false,
  });

  /// Yorum metninin kayıtta saklanan en fazla uzunluğu (kurallarla aynı).
  static const int maxTextLength = 120;

  static String likeId(String postId, String actorUid) =>
      'like_${postId}_$actorUid';

  static String commentDocId(String commentId) => 'comment_$commentId';

  static Map<String, dynamic> likeMap({
    required String postId,
    required String actorId,
    required String actorUsername,
  }) =>
      {
        'type': 'like',
        'actorId': actorId,
        'actorUsername': actorUsername,
        'postId': postId,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
        'pushed': false,
      };

  static Map<String, dynamic> commentMap({
    required String postId,
    required String commentId,
    required String actorId,
    required String actorUsername,
    required String text,
  }) =>
      {
        'type': 'comment',
        'actorId': actorId,
        'actorUsername': actorUsername,
        'postId': postId,
        'commentId': commentId,
        'text': text.length > maxTextLength
            ? '${text.substring(0, maxTextLength - 1)}…'
            : text,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
        'pushed': false,
      };

  factory ActivityItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return ActivityItem(
      id: doc.id,
      type: d['type'] == 'comment' ? ActivityType.comment : ActivityType.like,
      actorId: d['actorId'] as String? ?? '',
      actorUsername: d['actorUsername'] as String? ?? '',
      postId: d['postId'] as String? ?? '',
      commentId: d['commentId'] as String?,
      text: d['text'] as String?,
      // Sunucu zaman damgası yazılana kadar (yerel önbellek) null gelebilir.
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: d['read'] as bool? ?? false,
    );
  }
}
