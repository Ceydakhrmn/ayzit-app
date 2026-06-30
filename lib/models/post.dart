// =============================================
// models/post.dart
// Firestore posts/{postId} document model.
// =============================================

import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String content;
  final String authorId;
  final String authorUsername; // denorm
  final String authorAvatarSeed; // denorm
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool edited;
  final int likeCount;
  final int commentCount;
  final bool hidden;

  const Post({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorUsername,
    required this.authorAvatarSeed,
    required this.isAnonymous,
    required this.createdAt,
    this.updatedAt,
    this.edited = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.hidden = false,
  });

  /// Display name shown in the feed.
  /// Respects anonymity; UI should still fall back to a localized label.
  String get displayAuthorName => isAnonymous ? '' : authorUsername;

  Map<String, dynamic> toCreateMap() => {
        'content': content,
        'authorId': authorId,
        'authorUsername': authorUsername,
        'authorAvatarSeed': authorAvatarSeed,
        'isAnonymous': isAnonymous,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'edited': false,
        'likeCount': 0,
        'commentCount': 0,
        'hidden': false,
      };

  factory Post.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    return Post(
      id: doc.id,
      content: d['content'] as String? ?? '',
      authorId: d['authorId'] as String? ?? '',
      authorUsername: d['authorUsername'] as String? ?? '',
      authorAvatarSeed: d['authorAvatarSeed'] as String? ?? '',
      isAnonymous: d['isAnonymous'] as bool? ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
      edited: d['edited'] as bool? ?? false,
      likeCount: (d['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (d['commentCount'] as num?)?.toInt() ?? 0,
      hidden: d['hidden'] as bool? ?? false,
    );
  }
}
