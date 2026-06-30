// =============================================
// models/notification_prefs.dart
// =============================================

class NotificationPrefs {
  final bool appNotifications;
  final bool commentOnPost;
  final bool periodStart;
  final bool periodEnd;
  final bool exerciseReminder;
  final int exerciseReminderIntervalDays;
  final bool waterReminder;
  final int waterReminderIntervalMinutes;

  const NotificationPrefs({
    this.appNotifications = true,
    this.commentOnPost = true,
    this.periodStart = true,
    this.periodEnd = true,
    this.exerciseReminder = true,
    this.exerciseReminderIntervalDays = 2,
    this.waterReminder = false,
    this.waterReminderIntervalMinutes = 60,
  });

  NotificationPrefs copyWith({
    bool? appNotifications,
    bool? commentOnPost,
    bool? periodStart,
    bool? periodEnd,
    bool? exerciseReminder,
    int? exerciseReminderIntervalDays,
    bool? waterReminder,
    int? waterReminderIntervalMinutes,
  }) {
    return NotificationPrefs(
      appNotifications: appNotifications ?? this.appNotifications,
      commentOnPost: commentOnPost ?? this.commentOnPost,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      exerciseReminder: exerciseReminder ?? this.exerciseReminder,
      exerciseReminderIntervalDays: exerciseReminderIntervalDays ?? this.exerciseReminderIntervalDays,
      waterReminder: waterReminder ?? this.waterReminder,
      waterReminderIntervalMinutes: waterReminderIntervalMinutes ?? this.waterReminderIntervalMinutes,
    );
  }

  Map<String, dynamic> toMap() => {
        'appNotifications': appNotifications,
        'commentOnPost': commentOnPost,
        'periodStart': periodStart,
        'periodEnd': periodEnd,
        'exerciseReminder': exerciseReminder,
        'exerciseReminderIntervalDays': exerciseReminderIntervalDays,
        'waterReminder': waterReminder,
        'waterReminderIntervalMinutes': waterReminderIntervalMinutes,
      };

  factory NotificationPrefs.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const NotificationPrefs();
    return NotificationPrefs(
      appNotifications: map['appNotifications'] as bool? ?? true,
      commentOnPost: map['commentOnPost'] as bool? ?? true,
      periodStart: map['periodStart'] as bool? ?? true,
      periodEnd: map['periodEnd'] as bool? ?? true,
      exerciseReminder: map['exerciseReminder'] as bool? ?? true,
      exerciseReminderIntervalDays: (map['exerciseReminderIntervalDays'] as num?)?.toInt() ?? 2,
      waterReminder: map['waterReminder'] as bool? ?? false,
      waterReminderIntervalMinutes: (map['waterReminderIntervalMinutes'] as num?)?.toInt() ?? 60,
    );
  }
}
