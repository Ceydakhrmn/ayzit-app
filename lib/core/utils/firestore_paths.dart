// =============================================
// core/utils/firestore_paths.dart
// Central Firestore collection/document path constants.
// Keep everything here so changing a schema path is one-file-touch.
// =============================================

class FirestorePaths {
  FirestorePaths._();

  // Top-level collections
  static const String users = 'users';
  static const String usernames = 'usernames';
  static const String posts = 'posts';
  static const String reports = 'reports';
  static const String config = 'config';

  // Config documents
  static const String configProfanity = 'profanityList';

  // Sub-collection names (under users/{uid})
  static const String fcmTokens = 'fcmTokens';
  static const String cycleNotes = 'cycleNotes';
  static const String cycleHistory = 'cycleHistory';
  static const String waterIntake = 'waterIntake';
  static const String cycleMoods = 'cycleMoods';
  static const String appointments = 'appointments';

  // Sub-collection names (under posts/{postId})
  static const String likes = 'likes';
  static const String comments = 'comments';

  // Field keys (avoid magic strings)
  static const String fCreatedAt = 'createdAt';
  static const String fUpdatedAt = 'updatedAt';
  static const String fAuthorId = 'authorId';
  static const String fLikeCount = 'likeCount';
  static const String fCommentCount = 'commentCount';
  static const String fParentCommentId = 'parentCommentId';
  static const String fIsAnonymous = 'isAnonymous';
  static const String fHidden = 'hidden';
}
