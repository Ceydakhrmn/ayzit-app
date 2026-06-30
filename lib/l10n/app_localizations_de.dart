// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Ayzit';

  @override
  String get appSubtitle => 'Verfolge deinen Zyklus, teile und vernetze dich';

  @override
  String get calendarTab => 'Kalender';

  @override
  String get exerciseTab => 'Übung';

  @override
  String get socialTab => 'Sozial';

  @override
  String get profileTab => 'Profil';

  @override
  String get loginTitle => 'Willkommen';

  @override
  String get loginSubtitle => 'Melde dich an, um fortzufahren';

  @override
  String get registerTitle => 'Konto erstellen';

  @override
  String get registerSubtitle => 'Registriere dich und tritt der Community bei';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Passwort';

  @override
  String get confirmPasswordLabel => 'Passwort (bestätigen)';

  @override
  String get usernameLabel => 'Benutzername';

  @override
  String get displayNameLabel => 'Anzeigename';

  @override
  String get loginButton => 'ANMELDEN';

  @override
  String get registerButton => 'REGISTRIEREN';

  @override
  String get loginWithGoogle => 'Mit Google fortfahren';

  @override
  String get forgotPassword => 'Passwort vergessen';

  @override
  String get noAccountYet => 'Noch kein Konto?';

  @override
  String get alreadyHaveAccount => 'Schon ein Konto?';

  @override
  String get signUpLink => 'Registrieren';

  @override
  String get signInLink => 'Anmelden';

  @override
  String get passwordsDontMatch => 'Passwörter stimmen nicht überein';

  @override
  String get passwordTooShort => 'Passwort muss mindestens 6 Zeichen lang sein';

  @override
  String get emailInvalid => 'Gib eine gültige Email ein';

  @override
  String get emailRequired => 'Email ist erforderlich';

  @override
  String get passwordRequired => 'Passwort ist erforderlich';

  @override
  String get usernameTaken => 'Dieser Benutzername ist vergeben';

  @override
  String get usernameInvalid => 'Ungültiger Benutzername';

  @override
  String get verifyEmailTitle => 'Email bestätigen';

  @override
  String get verifyEmailSubtitle => 'Fast fertig';

  @override
  String get verifyEmailBody => 'Wir haben dir einen Bestätigungslink gesendet. Bitte prüfe dein Postfach.';

  @override
  String get verifyEmailPolling => 'Du wirst automatisch fortgesetzt, sobald verifiziert.';

  @override
  String get verifyEmailSent => 'Bestätigungs-Email gesendet';

  @override
  String get verifiedButton => 'ICH HABE VERIFIZIERT';

  @override
  String get resendVerification => 'Email erneut senden';

  @override
  String get forgotPasswordTitle => 'Passwort vergessen';

  @override
  String get forgotPasswordSubtitle => 'Wir senden dir einen Reset-Link';

  @override
  String get sendResetLink => 'RESET-LINK SENDEN';

  @override
  String get resetLinkSent => 'Link gesendet';

  @override
  String get backToLogin => 'ZURÜCK ZUR ANMELDUNG';

  @override
  String get socialLatest => 'Neueste';

  @override
  String get socialPopular => 'Beliebt';

  @override
  String get newPost => 'Neuer Beitrag';

  @override
  String get editPost => 'Beitrag bearbeiten';

  @override
  String get postHint => 'Was denkst du?';

  @override
  String get postAnonymously => 'Anonym posten';

  @override
  String get postAnonymouslyHint => 'Dein Name erscheint nicht im Feed';

  @override
  String get share => 'TEILEN';

  @override
  String get saveChanges => 'SPEICHERN';

  @override
  String get emptyPostError => 'Leere Beiträge sind nicht erlaubt';

  @override
  String get profanityDetected => 'Inhalt verstößt gegen die Richtlinien';

  @override
  String get noPostsYet => 'Noch keine Beiträge';

  @override
  String get anonymousUser => 'Anonym';

  @override
  String get editedLabel => 'bearbeitet';

  @override
  String get deletePostTitle => 'Beitrag löschen';

  @override
  String get deletePostConfirm => 'Diesen Beitrag wirklich löschen?';

  @override
  String get commentsTitle => 'Kommentare';

  @override
  String get writeComment => 'Kommentar schreiben...';

  @override
  String get reply => 'Antworten';

  @override
  String replyingTo(String username) {
    return 'Antwort an $username';
  }

  @override
  String get noComments => 'Noch keine Kommentare. Sei der Erste!';

  @override
  String get deleteCommentTitle => 'Kommentar löschen';

  @override
  String get deleteCommentConfirm => 'Diesen Kommentar wirklich löschen?';

  @override
  String get reportPost => 'Melden';

  @override
  String get reportTitle => 'Melden';

  @override
  String get reportReasonHint => 'Wähle einen Grund';

  @override
  String get reportReasonSpam => 'Spam';

  @override
  String get reportReasonHarassment => 'Belästigung';

  @override
  String get reportReasonInappropriate => 'Unangemessen';

  @override
  String get reportReasonHate => 'Hassrede';

  @override
  String get reportReasonOther => 'Sonstiges';

  @override
  String get reportDescription => 'Beschreibung (optional)';

  @override
  String get reportThanks => 'Meldung erhalten, danke';

  @override
  String get reportAlreadyExists => 'Du hast das bereits gemeldet';

  @override
  String get profileEdit => 'Profil bearbeiten';

  @override
  String get profileSettings => 'Einstellungen';

  @override
  String get profileLogout => 'Abmelden';

  @override
  String get confirmLogoutTitle => 'Abmelden';

  @override
  String get confirmLogoutMsg => 'Möchtest du dich wirklich abmelden?';

  @override
  String get cancelAction => 'Abbrechen';

  @override
  String get myPosts => 'Meine Beiträge';

  @override
  String get statsPosts => 'Beiträge';

  @override
  String get statsLikes => 'Likes';

  @override
  String get noMyPosts => 'Du hast noch keine Beiträge';

  @override
  String get dangerZone => 'Gefahrenzone';

  @override
  String get deleteAccount => 'KONTO LÖSCHEN';

  @override
  String get deleteAccountConfirm => 'Dies kann nicht rückgängig gemacht werden. Alle deine Daten werden gelöscht. Fortfahren?';

  @override
  String get changePassword => 'Passwort ändern (optional)';

  @override
  String get currentPasswordLabel => 'Aktuelles Passwort';

  @override
  String get newPasswordLabel => 'Neues Passwort';

  @override
  String get changesSaved => 'Änderungen gespeichert';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get generalSettings => 'Allgemein';

  @override
  String get appPurpose => 'App-Zweck';

  @override
  String get modePeriodTrack => 'Zyklus-Tracking';

  @override
  String get modePeriodTrackDesc => 'Verfolge deinen Menstruationszyklus';

  @override
  String get modePregnancy => 'Schwangerschaft';

  @override
  String get modePregnancyDesc => 'Verfolge deine Schwangerschaft';

  @override
  String get modeTryConceive => 'Kinderwunsch';

  @override
  String get modeTryConceiveDesc => 'Fruchtbare Tage verfolgen';

  @override
  String get notificationsSection => 'Benachrichtigungen';

  @override
  String get notifCommentOnPost => 'Kommentar zu meinem Beitrag';

  @override
  String get notifCommentOnPostDesc => 'Benachrichtigen, wenn jemand kommentiert';

  @override
  String get notifPeriodStart => 'Periode begonnen';

  @override
  String get notifPeriodStartDesc => 'Erinnere mich, wenn meine Periode fällig ist';

  @override
  String get notifPeriodEnd => 'Periode beendet';

  @override
  String get notifPeriodEndDesc => 'Erinnere mich am Ende';

  @override
  String get notifExerciseReminder => 'Trainingserinnerung';

  @override
  String get notifExerciseReminderDesc => 'Zweimal pro Woche';

  @override
  String get themeSection => 'Design';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeSystem => 'System';

  @override
  String get cycleSection => 'Zyklus';

  @override
  String get cycleLengthLabel => 'Durchschnittliche Zykluslänge';

  @override
  String get periodLengthLabel => 'Periodenlänge';

  @override
  String get errorGeneric => 'Etwas ist schief gelaufen';

  @override
  String get tryAgain => 'Erneut versuchen';

  // ── Calendar / Home ─────────────────────────────────────────────────────
  @override
  String get calendarColorsTooltip => 'Calendar Colors';

  @override
  String get legendTitle => "Here's a quick guide.";

  @override
  String get legendSubtitle => 'Colors indicate cycle phases. I\'ll give you tips based on these. ;)';

  @override
  String get legendPeriodHeavy => 'Period (heavy).';

  @override
  String get legendPeriodLight => 'Period (light).';

  @override
  String get legendOvulation => 'Ovulation day.';

  @override
  String get legendFertileHigh => 'Fertility — highest.';

  @override
  String get legendFertileMedium => 'Fertility — moderate.';

  @override
  String get legendFertileLow => 'Fertility — low.';

  @override
  String get legendBlend => 'Faded colors are my predictions.';

  @override
  String get legendDot => 'Indicates data entered for that day.';

  @override
  String get gotIt => 'GOT IT';

  @override
  String get logSymptomBtn => 'LOG SYMPTOM';

  @override
  String get startPeriodBtn => 'START PERIOD';

  @override
  String get endPeriodBtn => 'END PERIOD';

  @override
  String get periodStartedSnack => 'Period started!';

  @override
  String get periodEndedSnack => 'Period ended!';

  @override
  String get conceptionQuestion => 'How are you planning to conceive?';

  @override
  String get conceptionNatural => 'Natural';

  @override
  String get conceptionIUI => 'IUI';

  @override
  String get conceptionIVF => 'IVF';

  // ── Calendar grid ────────────────────────────────────────────────────────
  @override
  String get satBanner => 'Tap a day on the calendar to select your last period date.';

  @override
  String get satDialogTitle => 'Last Period Date';

  @override
  String get satDialogBody => 'set as your last menstrual period (LMP)?\n\nYour estimated due date will be calculated automatically.';

  @override
  String get satDialogSetBtn => 'Set';

  @override
  String get cancelBtn => 'Cancel';

  // ── Pregnancy day sheet ──────────────────────────────────────────────────
  @override
  String get satBadgeLabel => 'Last Menstrual Period (LMP)';

  @override
  String get dueDateBadgeLabel => 'Estimated Due Date';

  @override
  String get babyDevTitle => 'Baby Development';

  @override
  String get babyZodiacTitle => "Baby's Zodiac Sign";

  @override
  String get satNoteBody => 'This date is set as the start of your pregnancy (Last Menstrual Period). All week calculations are made from this date.';

  @override
  String get weekLabel => ' Week';

  // ── Pregnancy calculator ─────────────────────────────────────────────────
  @override
  String get pregnancyCalcTitle => 'Pregnancy Calculator';

  @override
  String get satInputLabel => 'Last Menstrual Period (LMP)';

  @override
  String get cycleLengthInputLabel => 'Average Cycle Length';

  @override
  String get calculateBtn => 'Calculate';

  @override
  String get dueDateResult => 'Estimated Due Date';

  @override
  String get pregnancyWeekResult => 'Pregnancy Week';

  @override
  String get detailInfoBtn => '📖 Full Article';

  // ── Baby development card ────────────────────────────────────────────────
  @override
  String get babyDevCardTitle => "Baby's Development";

  @override
  String get maternalChangesTitle => 'Maternal Changes';

  @override
  String get weekPrefix => ' Week';

  // ── Settings ─────────────────────────────────────────────────────────────
  @override
  String get languageSection => 'Language';

  @override
  String get languageTurkish => 'Turkish';

  @override
  String get languageEnglish => 'English';

  // ── Fertility cards ──────────────────────────────────────────────────────
  @override
  String get fertilityPrepTitle => 'Conception Preparation';

  @override
  String get fertilityPrepSubtitle => 'Start preparing 3 months before trying to conceive';

  @override
  String get fertilityPrepSummary => 'Get ready for a healthy pregnancy with folic acid, health checks, nutrition, and lifestyle changes.';

  @override
  String get pregnancySymptomsTitle => 'Pregnancy Symptoms';

  @override
  String get pregnancySymptomsSubtitle => 'Early signs and diagnostic methods';

  @override
  String get pregnancySymptomsSummary => 'Missed period, breast tenderness, nausea and more. When to test, when to see a doctor?';

  @override
  String get iuiCardTitle => 'IUI Treatment';

  @override
  String get iuiCardSubtitle => 'First-line treatment before IVF';

  @override
  String get iuiCardSummary => 'A painless assisted reproduction method where sperm is placed directly into the uterus. Success rate 10–30%.';

  @override
  String get ivfCardTitle => 'IVF Treatment';

  @override
  String get ivfCardSubtitle => 'High success rate assisted reproduction';

  @override
  String get ivfCardSummary => 'Eggs and sperm are fertilized in a lab, then placed in the uterus. 35–45% success rate under age 35.';

  @override
  String get detailInfoBtn2 => 'Full Details';

  // ── Important days card ──────────────────────────────────────────────────
  @override
  String get importantDaysTitle => 'Important Days';

  // ── Appointments card ────────────────────────────────────────────────────
  @override
  String get appointmentsTitle => 'Appointments';

  @override
  String get noAppointments => 'No appointments';

  @override
  String get addAppointment => 'Add Appointment';

  // ── Info card ─────────────────────────────────────────────────────────────
  @override String get selectDayLabel => 'Select a day';
  @override String get okBtn => 'OK';

  // ── Cycle summary card ────────────────────────────────────────────────────
  @override String get cycleSummaryTitle => 'Summary';
  @override String get historyLabel => 'History';
  @override String get yourSummaryLabel => 'Your Summary';
  @override String get currentPeriodLabel => 'Current Period';
  @override String get daysUnit => 'Days';
  @override String get periodDurationSuffix => 'Day Period';
  @override String get periodStartPrefix => 'Start';
  @override String get lastPeriodLabel => 'Last Period';
  @override String get normalPeriodDurationLabel => 'Normal Period Duration';
  @override String get normalCycleLengthLabel => 'Normal Cycle Length';
  @override String get daysAgoSuffix => 'Days Ago';

  // ── Symptom sheet ─────────────────────────────────────────────────────────
  @override String get symptomSheetTitle => 'Log Symptoms';
  @override String get symptomSheetHint => 'Select symptoms you feel today';
  @override String get physicalLabel => 'Physical';
  @override String get emotionalLabel => 'Emotional';
  @override String get saveBtn => 'SAVE';
  @override String get symptomsSavedSnack => 'Symptoms saved!';

  // ── Common action buttons ─────────────────────────────────────────────────
  @override String get deleteBtn => 'Delete';
  @override String get editBtn => 'Edit';
  @override String get reportBtn => 'Report';
  @override String get logoutBtn => 'Log Out';
  @override String get profileLabel => 'Profile';
  @override String get settingsLabel => 'Settings';
  @override String get editProfileLabel => 'Edit Profile';
  @override String get myPostsLabel => 'My Posts';
  @override String get dismissBtn => 'Cancel';
}
