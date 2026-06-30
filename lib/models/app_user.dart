// =============================================
// models/app_user.dart
// Firestore users/{uid} document model.
// =============================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_prefs.dart';

enum AppThemeMode { light, dark, system }

class UserPreferences {
  final AppThemeMode themeMode;
  final String locale; // tr, en, fr, de, es
  final NotificationPrefs notifications;

  const UserPreferences({
    this.themeMode = AppThemeMode.system,
    this.locale = 'tr',
    this.notifications = const NotificationPrefs(),
  });

  UserPreferences copyWith({
    AppThemeMode? themeMode,
    String? locale,
    NotificationPrefs? notifications,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      notifications: notifications ?? this.notifications,
    );
  }

  Map<String, dynamic> toMap() => {
        'themeMode': themeMode.name,
        'locale': locale,
        'notifications': notifications.toMap(),
      };

  factory UserPreferences.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const UserPreferences();
    final modeStr = map['themeMode'] as String? ?? 'system';
    return UserPreferences(
      themeMode: AppThemeMode.values.firstWhere(
        (m) => m.name == modeStr,
        orElse: () => AppThemeMode.system,
      ),
      locale: map['locale'] as String? ?? 'tr',
      notifications: NotificationPrefs.fromMap(
        map['notifications'] as Map<String, dynamic>?,
      ),
    );
  }
}

class AppUser {
  final String uid;
  final String email;
  final String username; // lowercase, unique
  final String displayName;
  final String avatarSeed; // used for color generation
  final DateTime createdAt;
  final int postCount;
  final int likesReceived;
  final String appMode; // reglTakip | hamileTakip | hamilleKalma
  final UserPreferences preferences;

  const AppUser({
    required this.uid,
    required this.email,
    required this.username,
    required this.displayName,
    required this.avatarSeed,
    required this.createdAt,
    this.postCount = 0,
    this.likesReceived = 0,
    this.appMode = '',
    this.preferences = const UserPreferences(),
  });

  AppUser copyWith({
    String? email,
    String? username,
    String? displayName,
    String? avatarSeed,
    int? postCount,
    int? likesReceived,
    String? appMode,
    UserPreferences? preferences,
  }) {
    return AppUser(
      uid: uid,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarSeed: avatarSeed ?? this.avatarSeed,
      createdAt: createdAt,
      postCount: postCount ?? this.postCount,
      likesReceived: likesReceived ?? this.likesReceived,
      appMode: appMode ?? this.appMode,
      preferences: preferences ?? this.preferences,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'username': username,
        'displayName': displayName,
        'avatarSeed': avatarSeed,
        'createdAt': Timestamp.fromDate(createdAt),
        'postCount': postCount,
        'likesReceived': likesReceived,
        'appMode': appMode,
        'preferences': preferences.toMap(),
      };

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return AppUser(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      username: data['username'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      avatarSeed: data['avatarSeed'] as String? ?? doc.id,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      postCount: (data['postCount'] as num?)?.toInt() ?? 0,
      likesReceived: (data['likesReceived'] as num?)?.toInt() ?? 0,
      appMode: data['appMode'] as String? ?? '',
      preferences: UserPreferences.fromMap(
        data['preferences'] as Map<String, dynamic>?,
      ),
    );
  }
}
