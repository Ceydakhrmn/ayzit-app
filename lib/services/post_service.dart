// =============================================
// services/post_service.dart
// Posts CRUD + pagination + like toggle.
//
// Like/unlike uses a Firestore transaction to keep the
// posts/{id}.likeCount denorm in sync with the
// posts/{id}/likes/{uid} subcollection membership.
//
// Popularity (this month) query needs a composite index on
// (createdAt ASC, likeCount DESC) — see firestore.indexes.json.
// =============================================

import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/utils/firestore_paths.dart';
import '../models/activity_item.dart';
import '../models/post.dart';

class PagedPosts {
  final List<Post> posts;
  final DocumentSnapshot<Map<String, dynamic>>? lastDoc;
  final bool hasMore;
  const PagedPosts({
    required this.posts,
    required this.lastDoc,
    required this.hasMore,
  });
}

class PostService {
  PostService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _postsCol =>
      _firestore.collection(FirestorePaths.posts);

  DocumentReference<Map<String, dynamic>> _postRef(String id) =>
      _postsCol.doc(id);

  // ── Create ──
  Future<String> createPost({
    required String authorId,
    required String authorUsername,
    required String authorAvatarSeed,
    required String content,
    required bool isAnonymous,
  }) async {
    final ref = _postsCol.doc();
    final post = Post(
      id: ref.id,
      content: content.trim(),
      authorId: authorId,
      authorUsername: authorUsername,
      authorAvatarSeed: authorAvatarSeed,
      isAnonymous: isAnonymous,
      createdAt: DateTime.now(),
    );
    await ref.set(post.toCreateMap());
    return ref.id;
  }

  // ── Update (edit) ──
  Future<void> updatePostContent({
    required String postId,
    required String newContent,
  }) async {
    await _postRef(postId).update({
      'content': newContent.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
      'edited': true,
    });
  }

  // ── Delete ──
  /// Deletes the post document. Subcollections (likes, comments) are not
  /// deleted client-side — a Cloud Function or scheduled cleanup can do so.
  Future<void> deletePost(String postId) async {
    await _postRef(postId).delete();
  }

  // ── Pagination: Latest ──
  Future<PagedPosts> fetchLatest({
    int pageSize = 20,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    Query<Map<String, dynamic>> q = _postsCol
        .where('hidden', isEqualTo: false)
        .orderBy(FirestorePaths.fCreatedAt, descending: true)
        .limit(pageSize + 1);
    if (startAfter != null) {
      q = q.startAfterDocument(startAfter);
    }
    final snap = await q.get();
    final hasMore = snap.docs.length > pageSize;
    final pageDocs = snap.docs.take(pageSize).toList();
    return PagedPosts(
      posts: pageDocs.map(Post.fromDoc).toList(),
      lastDoc: pageDocs.isEmpty ? null : pageDocs.last,
      hasMore: hasMore,
    );
  }

  // ── Pagination: Popular this month (by likeCount DESC) ──
  Future<PagedPosts> fetchPopularThisMonth({
    int pageSize = 20,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    final now = DateTime.now();
    final monthStart = Timestamp.fromDate(DateTime(now.year, now.month, 1));

    Query<Map<String, dynamic>> q = _postsCol
        .where('hidden', isEqualTo: false)
        .where(FirestorePaths.fCreatedAt, isGreaterThanOrEqualTo: monthStart)
        .orderBy(FirestorePaths.fCreatedAt)
        .orderBy(FirestorePaths.fLikeCount, descending: true)
        .limit(pageSize + 1);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    final snap = await q.get();
    final hasMore = snap.docs.length > pageSize;
    final pageDocs = snap.docs.take(pageSize).toList();
    return PagedPosts(
      posts: pageDocs.map(Post.fromDoc).toList(),
      lastDoc: pageDocs.isEmpty ? null : pageDocs.last,
      hasMore: hasMore,
    );
  }

  // ── Posts by author (for profile) ──
  Future<PagedPosts> fetchByAuthor(
    String authorId, {
    int pageSize = 20,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    Query<Map<String, dynamic>> q = _postsCol
        .where(FirestorePaths.fAuthorId, isEqualTo: authorId)
        .orderBy(FirestorePaths.fCreatedAt, descending: true)
        .limit(pageSize + 1);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    final snap = await q.get();
    final hasMore = snap.docs.length > pageSize;
    final pageDocs = snap.docs.take(pageSize).toList();
    return PagedPosts(
      posts: pageDocs.map(Post.fromDoc).toList(),
      lastDoc: pageDocs.isEmpty ? null : pageDocs.last,
      hasMore: hasMore,
    );
  }

  // ── Profile stats ──
  /// Gönderi sayısı ve bu gönderilerin aldığı toplam beğeni. Kullanıcı
  /// dokümanındaki postCount / likesReceived sayaçlarını Cloud Functions
  /// güncelleyecekti ama yayında olmadığı için profil hep 0 gösteriyordu;
  /// bu yüzden kullanıcının gönderilerinden hesaplanır. (Firestore'un sum()
  /// sorgusu ek bir bileşik dizin isterdi; kişi başı gönderi sayısı az.)
  Future<({int posts, int likes})> authorStats(String authorId) async {
    final snap = await _postsCol
        .where(FirestorePaths.fAuthorId, isEqualTo: authorId)
        .get();
    var likes = 0;
    for (final doc in snap.docs) {
      likes += (doc.data()[FirestorePaths.fLikeCount] as num?)?.toInt() ?? 0;
    }
    return (posts: snap.docs.length, likes: likes);
  }

  // ── Live single-post listener (used by detail screen) ──
  Stream<Post?> postStream(String postId) {
    return _postRef(postId).snapshots().map(
          (snap) => snap.exists ? Post.fromDoc(snap) : null,
        );
  }

  // ── Like / Unlike ──
  /// Toggles the current user's like on a post. Returns the new like state.
  /// Performs a transaction to keep the denormalised likeCount in sync.
  /// [username] beğenenin kullanıcı adı; paylaşım sahibinin zil listesinde
  /// görünür. Boşsa kayıt yazılmaz (güvenlik kuralı kullanıcı adını doğrular).
  Future<bool> toggleLike({
    required String postId,
    required String uid,
    String username = '',
  }) async {
    final postRef = _postRef(postId);
    final likeRef = postRef.collection(FirestorePaths.likes).doc(uid);

    return await _firestore.runTransaction<bool>((tx) async {
      final likeSnap = await tx.get(likeRef);
      final postSnap = await tx.get(postRef);
      if (!postSnap.exists) return false;

      final authorId = postSnap.data()?[FirestorePaths.fAuthorId] as String?;
      final activityRef = (authorId == null || authorId == uid)
          ? null
          : _firestore
              .collection(FirestorePaths.users)
              .doc(authorId)
              .collection(FirestorePaths.activity)
              .doc(ActivityItem.likeId(postId, uid));

      if (likeSnap.exists) {
        tx.delete(likeRef);
        tx.update(postRef, {
          FirestorePaths.fLikeCount: FieldValue.increment(-1),
        });
        if (activityRef != null) tx.delete(activityRef);
        return false;
      } else {
        tx.set(likeRef, {
          FirestorePaths.fCreatedAt: FieldValue.serverTimestamp(),
        });
        tx.update(postRef, {
          FirestorePaths.fLikeCount: FieldValue.increment(1),
        });
        if (activityRef != null && username.isNotEmpty) {
          tx.set(
            activityRef,
            ActivityItem.likeMap(
                postId: postId, actorId: uid, actorUsername: username),
          );
        }
        return true;
      }
    });
  }

  /// Whether the given user currently likes this post.
  Future<bool> hasLiked({
    required String postId,
    required String uid,
  }) async {
    final snap = await _postRef(postId)
        .collection(FirestorePaths.likes)
        .doc(uid)
        .get();
    return snap.exists;
  }

  /// Live stream for the current user's like state on a post.
  Stream<bool> likeStream({required String postId, required String uid}) {
    return _postRef(postId)
        .collection(FirestorePaths.likes)
        .doc(uid)
        .snapshots()
        .map((snap) => snap.exists);
  }
}
