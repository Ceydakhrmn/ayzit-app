// =============================================
// models/comment.dart
// Firestore posts/{postId}/comments/{commentId} document model.
// =============================================

import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String content;
  final String authorId;
  final String authorUsername;
  final String authorAvatarSeed;
  final String? parentCommentId; // null = top-level
  final DateTime createdAt;
  final bool hidden;

  const Comment({
    required this.id,
    required this.postId,
    required this.content,
    required this.authorId,
    required this.authorUsername,
    required this.authorAvatarSeed,
    this.parentCommentId,
    required this.createdAt,
    this.hidden = false,
  });

  Map<String, dynamic> toCreateMap() => {
        'content': content,
        'authorId': authorId,
        'authorUsername': authorUsername,
        'authorAvatarSeed': authorAvatarSeed,
        'parentCommentId': parentCommentId,
        'createdAt': FieldValue.serverTimestamp(),
        'hidden': false,
      };

  factory Comment.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String postId,
  }) {
    final d = doc.data() ?? <String, dynamic>{};
    return Comment(
      id: doc.id,
      postId: postId,
      content: d['content'] as String? ?? '',
      authorId: d['authorId'] as String? ?? '',
      authorUsername: d['authorUsername'] as String? ?? '',
      authorAvatarSeed: d['authorAvatarSeed'] as String? ?? '',
      parentCommentId: d['parentCommentId'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      hidden: d['hidden'] as bool? ?? false,
    );
  }
}
