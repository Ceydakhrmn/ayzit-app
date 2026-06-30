// =============================================
// services/comment_service.dart
// Nested comments (max 2 levels). commentCount denorm is updated via
// transactions so the feed card counter stays in sync.
// =============================================

import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/utils/firestore_paths.dart';
import '../models/comment.dart';

class CommentService {
  CommentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _postRef(String postId) => _firestore
      .collection(FirestorePaths.posts)
      .doc(postId);

  CollectionReference<Map<String, dynamic>> _commentsCol(String postId) =>
      _postRef(postId).collection(FirestorePaths.comments);

  // ── Create ──
  Future<String> createComment({
    required String postId,
    required String authorId,
    required String authorUsername,
    required String authorAvatarSeed,
    required String content,
    String? parentCommentId,
  }) async {
    final commentsCol = _commentsCol(postId);
    final newRef = commentsCol.doc();
    final postRef = _postRef(postId);

    // Enforce max 2 levels: if parent is a reply itself, promote to its
    // parent so the tree never grows deeper than 2.
    String? normalizedParent = parentCommentId;
    if (parentCommentId != null) {
      final parentSnap = await commentsCol.doc(parentCommentId).get();
      final parentOfParent =
          parentSnap.data()?['parentCommentId'] as String?;
      if (parentOfParent != null) {
        normalizedParent = parentOfParent;
      }
    }

    final data = Comment(
      id: newRef.id,
      postId: postId,
      content: content.trim(),
      authorId: authorId,
      authorUsername: authorUsername,
      authorAvatarSeed: authorAvatarSeed,
      parentCommentId: normalizedParent,
      createdAt: DateTime.now(),
    ).toCreateMap();

    await _firestore.runTransaction((tx) async {
      tx.set(newRef, data);
      tx.update(postRef, {
        FirestorePaths.fCommentCount: FieldValue.increment(1),
      });
    });
    return newRef.id;
  }

  // ── Delete (author only per Firestore rules) ──
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final commentRef = _commentsCol(postId).doc(commentId);
    final postRef = _postRef(postId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(commentRef);
      if (!snap.exists) return;
      tx.delete(commentRef);
      tx.update(postRef, {
        FirestorePaths.fCommentCount: FieldValue.increment(-1),
      });
    });
  }

  // ── Reads ──
  /// Stream all comments for a post, ordered by creation time.
  /// UI code is responsible for building the nested view (parent → replies).
  Stream<List<Comment>> streamComments(String postId) {
    return _commentsCol(postId)
        .where('hidden', isEqualTo: false)
        .orderBy(FirestorePaths.fCreatedAt)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Comment.fromDoc(d, postId: postId)).toList());
  }
}
