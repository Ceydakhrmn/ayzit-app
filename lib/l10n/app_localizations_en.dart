// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ayzit';

  @override
  String get btnContinue => 'CONTINUE';

  @override
  String get appSubtitle => 'Track your cycle, share and connect';

  @override
  String get calendarTab => 'Calendar';

  @override
  String get exerciseTab => 'Exercise';

  @override
  String get socialTab => 'Social';

  @override
  String get profileTab => 'Profile';

  @override
  String get loginTitle => 'Welcome';

  @override
  String get loginSubtitle => 'Sign in to continue';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerSubtitle => 'Sign up to join the community';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Password (confirm)';

  @override
  String get usernameLabel => 'Username';

  @override
  String get displayNameLabel => 'Display name';

  @override
  String get loginButton => 'SIGN IN';

  @override
  String get registerButton => 'SIGN UP';

  @override
  String get loginWithGoogle => 'Continue with Google';

  @override
  String get forgotPassword => 'Forgot password';

  @override
  String get noAccountYet => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get signUpLink => 'Sign up';

  @override
  String get signInLink => 'Sign in';

  @override
  String get passwordsDontMatch => 'Passwords do not match';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get usernameTaken => 'That username is taken';

  @override
  String get usernameInvalid => 'Invalid username';

  @override
  String get verifyEmailTitle => 'Verify email';

  @override
  String get verifyEmailSubtitle => 'Almost there';

  @override
  String get verifyEmailBody => 'We sent a verification link to your email. Please check your inbox.';

  @override
  String get verifyEmailPolling => 'You\'ll continue automatically once verified.';

  @override
  String get verifyEmailSent => 'Verification email sent';

  @override
  String get verifiedButton => 'I\'VE VERIFIED';

  @override
  String get resendVerification => 'Resend email';

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get forgotPasswordSubtitle => 'We\'ll send you a reset link';

  @override
  String get sendResetLink => 'SEND RESET LINK';

  @override
  String get resetLinkSent => 'Reset link sent';

  @override
  String get backToLogin => 'BACK TO SIGN IN';

  @override
  String get socialLatest => 'Latest';

  @override
  String get socialPopular => 'Popular';

  @override
  String get newPost => 'New Post';

  @override
  String get editPost => 'Edit Post';

  @override
  String get postHint => 'What\'s on your mind?';

  @override
  String get postAnonymously => 'Post anonymously';

  @override
  String get postAnonymouslyHint => 'Your username won\'t appear in the feed';

  @override
  String get share => 'SHARE';

  @override
  String get saveChanges => 'SAVE';

  @override
  String get emptyPostError => 'You can\'t post empty content';

  @override
  String get profanityDetected => 'Content violates community guidelines';

  @override
  String get noPostsYet => 'No posts yet';

  @override
  String get anonymousUser => 'Anonymous';

  @override
  String get editedLabel => 'edited';

  @override
  String get deletePostTitle => 'Delete Post';

  @override
  String get deletePostConfirm => 'Are you sure you want to delete this post?';

  @override
  String get commentsTitle => 'Comments';

  @override
  String get writeComment => 'Write a comment...';

  @override
  String get reply => 'Reply';

  @override
  String replyingTo(String username) {
    return 'Replying to $username';
  }

  @override
  String get noComments => 'No comments yet. Be the first!';

  @override
  String get deleteCommentTitle => 'Delete Comment';

  @override
  String get deleteCommentConfirm => 'Are you sure you want to delete this comment?';

  @override
  String get reportPost => 'Report';

  @override
  String get reportTitle => 'Report';

  @override
  String get reportReasonHint => 'Please select a reason';

  @override
  String get reportReasonSpam => 'Spam';

  @override
  String get reportReasonHarassment => 'Harassment';

  @override
  String get reportReasonInappropriate => 'Inappropriate';

  @override
  String get reportReasonHate => 'Hate speech';

  @override
  String get reportReasonOther => 'Other';

  @override
  String get reportDescription => 'Description (optional)';

  @override
  String get reportThanks => 'Report received, thank you';

  @override
  String get reportAlreadyExists => 'You already reported this';

  @override
  String get profileEdit => 'Edit Profile';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileLogout => 'Log Out';

  @override
  String get confirmLogoutTitle => 'Log Out';

  @override
  String get confirmLogoutMsg => 'Are you sure you want to sign out?';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get myPosts => 'My Posts';

  @override
  String get statsPosts => 'Posts';

  @override
  String get statsLikes => 'Likes';

  @override
  String get noMyPosts => 'You have no posts yet';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get deleteAccount => 'DELETE ACCOUNT';

  @override
  String get deleteAccountConfirm => 'This cannot be undone. All your data, posts and comments will be deleted. Continue?';

  @override
  String get changePassword => 'Change password (optional)';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get changesSaved => 'Changes saved';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get generalSettings => 'General';

  @override
  String get appPurpose => 'App purpose';

  @override
  String get modePeriodTrack => 'Period Tracking';

  @override
  String get modePeriodTrackDesc => 'Track your menstrual cycle';

  @override
  String get modePregnancy => 'Pregnancy';

  @override
  String get modePregnancyDesc => 'Track your pregnancy';

  @override
  String get modeTryConceive => 'Ovulation & Conceive';

  @override
  String get modeTryConceiveDesc => 'Ovulation tracking & fertility windows';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get notifCommentOnPost => 'Comment on my post';

  @override
  String get notifCommentOnPostDesc => 'Notify me when someone comments on my post';

  @override
  String get notifPeriodStart => 'Period started';

  @override
  String get notifPeriodStartDesc => 'Remind me when my period is due';

  @override
  String get notifPeriodEnd => 'Period ended';

  @override
  String get notifPeriodEndDesc => 'Remind me when my period ends';

  @override
  String get notifExerciseReminder => 'Exercise reminder';

  @override
  String get notifExerciseReminderDesc => 'Twice a week';

  @override
  String get themeSection => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'Follow system';

  @override
  String get cycleSection => 'Cycle';

  @override
  String get cycleLengthLabel => 'Average cycle length';

  @override
  String get periodLengthLabel => 'Period length';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get tryAgain => 'Try again';

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
