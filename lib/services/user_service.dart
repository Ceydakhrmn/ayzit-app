// =============================================
// services/user_service.dart
// Firestore-side user profile management:
//   • users/{uid} doc CRUD
//   • usernames/{username} unique reservation via transaction
//   • stats (postCount, likesReceived) denorm updates
//   • user + subcollection deletion on account delete
// =============================================

import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/utils/firestore_paths.dart';
import '../models/app_user.dart';
import '../models/notification_prefs.dart';

class UsernameTaken implements Exception {
  final String username;
  UsernameTaken(this.username);
  @override
  String toString() => 'Username already taken: $username';
}

class UserService {
  UserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection(FirestorePaths.users);

  CollectionReference<Map<String, dynamic>> get _usernamesCol =>
      _firestore.collection(FirestorePaths.usernames);

  DocumentReference<Map<String, dynamic>> userDoc(String uid) =>
      _usersCol.doc(uid);

  // ── Username validation ──
  static final RegExp _usernameRegex = RegExp(r'^[a-z0-9_\.]{3,20}$');

  static String normalizeUsername(String raw) =>
      raw.trim().toLowerCase();

  static bool isValidUsername(String username) =>
      _usernameRegex.hasMatch(normalizeUsername(username));

  /// Checks if a username is available. Cheap read — NOT atomic.
  /// Use [createUserProfile] (which uses a transaction) for the real claim.
  Future<bool> isUsernameAvailable(String username) async {
    final doc = await _usernamesCol.doc(normalizeUsername(username)).get();
    return !doc.exists;
  }

  /// Atomically creates users/{uid} AND usernames/{username}.
  /// Throws [UsernameTaken] if the username is already claimed.
  Future<AppUser> createUserProfile({
    required String uid,
    required String email,
    required String username,
    required String displayName,
  }) async {
    final normUsername = normalizeUsername(username);
    if (!isValidUsername(normUsername)) {
      throw ArgumentError.value(
          username, 'username', 'Invalid username format');
    }

    final userRef = userDoc(uid);
    final usernameRef = _usernamesCol.doc(normUsername);

    final now = DateTime.now();
    final newUser = AppUser(
      uid: uid,
      email: email,
      username: normUsername,
      displayName: displayName.trim(),
      avatarSeed: normUsername,
      createdAt: now,
    );

    await _firestore.runTransaction((tx) async {
      final existingUsername = await tx.get(usernameRef);
      if (existingUsername.exists) {
        throw UsernameTaken(normUsername);
      }
      tx.set(usernameRef, {
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      tx.set(userRef, newUser.toMap());
    });

    return newUser;
  }

  /// Ensures a Firestore user doc exists for a Firebase Auth user that
  /// signed in via Google for the first time. Generates a unique username
  /// derived from email if the user doesn't already have a profile.
  Future<AppUser> ensureUserProfileForGoogle({
    required String uid,
    required String email,
    required String displayName,
  }) async {
    final existing = await userDoc(uid).get();
    if (existing.exists) {
      return AppUser.fromDoc(existing);
    }

    // Generate a username from email local part, fall back with random digits
    final base =
        email.split('@').first.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_\.]'), '');
    final seed = base.isEmpty ? 'user' : base;

    // Try base, base1, base2, ... until free (bounded)
    for (var i = 0; i < 20; i++) {
      final candidate =
          (i == 0 ? seed : '$seed$i').substring(0, seed.length > 18 ? 18 : seed.length).padRight(3, '0');
      try {
        return await createUserProfile(
          uid: uid,
          email: email,
          username: candidate,
          displayName: displayName.isEmpty ? candidate : displayName,
        );
      } on UsernameTaken {
        continue;
      }
    }

    // Ultimate fallback: uid-prefixed username
    return await createUserProfile(
      uid: uid,
      email: email,
      username: 'u${uid.substring(0, 8).toLowerCase()}',
      displayName: displayName.isEmpty ? 'User' : displayName,
    );
  }

  // ── Reads ──
  Future<AppUser?> fetchUser(String uid) async {
    final doc = await userDoc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromDoc(doc);
  }

  Stream<AppUser?> userStream(String uid) {
    return userDoc(uid).snapshots().map(
          (snap) => snap.exists ? AppUser.fromDoc(snap) : null,
        );
  }

  // ── Profile updates ──
  Future<void> updateDisplayName(String uid, String displayName) async {
    await userDoc(uid).update({'displayName': displayName.trim()});
  }

  /// Change username atomically — releases the old one, claims the new.
  Future<void> changeUsername({
    required String uid,
    required String oldUsername,
    required String newUsername,
  }) async {
    final oldLower = normalizeUsername(oldUsername);
    final newLower = normalizeUsername(newUsername);
    if (oldLower == newLower) return;
    if (!isValidUsername(newLower)) {
      throw ArgumentError.value(
          newUsername, 'username', 'Invalid username format');
    }

    final userRef = userDoc(uid);
    final oldRef = _usernamesCol.doc(oldLower);
    final newRef = _usernamesCol.doc(newLower);

    await _firestore.runTransaction((tx) async {
      final newSnap = await tx.get(newRef);
      if (newSnap.exists) throw UsernameTaken(newLower);
      tx.delete(oldRef);
      tx.set(newRef, {
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      tx.update(userRef, {
        'username': newLower,
        'avatarSeed': newLower,
      });
    });
  }

  Future<void> updateAppMode(String uid, String appMode) async {
    await userDoc(uid).update({'appMode': appMode});
  }

  Future<void> updateThemeMode(String uid, AppThemeMode mode) async {
    await userDoc(uid).update({'preferences.themeMode': mode.name});
  }

  Future<void> updateLocale(String uid, String locale) async {
    await userDoc(uid).update({'preferences.locale': locale});
  }

  Future<void> updateNotificationPrefs(
      String uid, NotificationPrefs prefs) async {
    await userDoc(uid).update({'preferences.notifications': prefs.toMap()});
  }

  // ── Stats (denorm) ──
  Future<void> incrementPostCount(String uid, int delta) async {
    await userDoc(uid).update({
      'postCount': FieldValue.increment(delta),
    });
  }

  Future<void> incrementLikesReceived(String uid, int delta) async {
    await userDoc(uid).update({
      'likesReceived': FieldValue.increment(delta),
    });
  }

  // ── Account deletion ──
  /// Deletes the users/{uid} doc, its subcollections (best-effort) and
  /// releases the username reservation. Caller is responsible for then
  /// calling AuthService.deleteAuthAccount().
  Future<void> deleteUserProfile(String uid, String username) async {
    final userRef = userDoc(uid);
    final usernameRef = _usernamesCol.doc(normalizeUsername(username));

    // Best-effort delete of sub-collections (one page each, not recursive)
    Future<void> wipeSub(String name) async {
      final snap = await userRef.collection(name).get();
      for (final d in snap.docs) {
        await d.reference.delete();
      }
    }

    await wipeSub(FirestorePaths.fcmTokens);
    await wipeSub(FirestorePaths.cycleNotes);
    await wipeSub(FirestorePaths.cycleHistory);
    await wipeSub(FirestorePaths.waterIntake);

    await _firestore.runTransaction((tx) async {
      tx.delete(usernameRef);
      tx.delete(userRef);
    });
  }
}
