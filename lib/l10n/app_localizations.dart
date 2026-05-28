import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Lunora'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your cycle, share and connect'**
  String get appSubtitle;

  /// No description provided for @calendarTab.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTab;

  /// No description provided for @exerciseTab.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exerciseTab;

  /// No description provided for @socialTab.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get socialTab;

  /// No description provided for @profileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get loginSubtitle;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up to join the community'**
  String get registerSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password (confirm)'**
  String get confirmPasswordLabel;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @displayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayNameLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'SIGN UP'**
  String get registerButton;

  /// No description provided for @loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginWithGoogle;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPassword;

  /// No description provided for @noAccountYet.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccountYet;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUpLink;

  /// No description provided for @signInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInLink;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDontMatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalid;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @usernameTaken.
  ///
  /// In en, this message translates to:
  /// **'That username is taken'**
  String get usernameTaken;

  /// No description provided for @usernameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid username'**
  String get usernameInvalid;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Almost there'**
  String get verifyEmailSubtitle;

  /// No description provided for @verifyEmailBody.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to your email. Please check your inbox.'**
  String get verifyEmailBody;

  /// No description provided for @verifyEmailPolling.
  ///
  /// In en, this message translates to:
  /// **'You\'ll continue automatically once verified.'**
  String get verifyEmailPolling;

  /// No description provided for @verifyEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent'**
  String get verifyEmailSent;

  /// No description provided for @verifiedButton.
  ///
  /// In en, this message translates to:
  /// **'I\'VE VERIFIED'**
  String get verifiedButton;

  /// No description provided for @resendVerification.
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get resendVerification;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send you a reset link'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'SEND RESET LINK'**
  String get sendResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent'**
  String get resetLinkSent;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'BACK TO SIGN IN'**
  String get backToLogin;

  /// No description provided for @socialLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get socialLatest;

  /// No description provided for @socialPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get socialPopular;

  /// No description provided for @newPost.
  ///
  /// In en, this message translates to:
  /// **'New Post'**
  String get newPost;

  /// No description provided for @editPost.
  ///
  /// In en, this message translates to:
  /// **'Edit Post'**
  String get editPost;

  /// No description provided for @postHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get postHint;

  /// No description provided for @postAnonymously.
  ///
  /// In en, this message translates to:
  /// **'Post anonymously'**
  String get postAnonymously;

  /// No description provided for @postAnonymouslyHint.
  ///
  /// In en, this message translates to:
  /// **'Your username won\'t appear in the feed'**
  String get postAnonymouslyHint;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'SHARE'**
  String get share;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get saveChanges;

  /// No description provided for @emptyPostError.
  ///
  /// In en, this message translates to:
  /// **'You can\'t post empty content'**
  String get emptyPostError;

  /// No description provided for @profanityDetected.
  ///
  /// In en, this message translates to:
  /// **'Content violates community guidelines'**
  String get profanityDetected;

  /// No description provided for @noPostsYet.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get noPostsYet;

  /// No description provided for @anonymousUser.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymousUser;

  /// No description provided for @editedLabel.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get editedLabel;

  /// No description provided for @deletePostTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Post'**
  String get deletePostTitle;

  /// No description provided for @deletePostConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this post?'**
  String get deletePostConfirm;

  /// No description provided for @commentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentsTitle;

  /// No description provided for @writeComment.
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get writeComment;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @replyingTo.
  ///
  /// In en, this message translates to:
  /// **'Replying to {username}'**
  String replyingTo(String username);

  /// No description provided for @noComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet. Be the first!'**
  String get noComments;

  /// No description provided for @deleteCommentTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Comment'**
  String get deleteCommentTitle;

  /// No description provided for @deleteCommentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this comment?'**
  String get deleteCommentConfirm;

  /// No description provided for @reportPost.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportPost;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportTitle;

  /// No description provided for @reportReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Please select a reason'**
  String get reportReasonHint;

  /// No description provided for @reportReasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get reportReasonSpam;

  /// No description provided for @reportReasonHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get reportReasonHarassment;

  /// No description provided for @reportReasonInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate'**
  String get reportReasonInappropriate;

  /// No description provided for @reportReasonHate.
  ///
  /// In en, this message translates to:
  /// **'Hate speech'**
  String get reportReasonHate;

  /// No description provided for @reportReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reportReasonOther;

  /// No description provided for @reportDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get reportDescription;

  /// No description provided for @reportThanks.
  ///
  /// In en, this message translates to:
  /// **'Report received, thank you'**
  String get reportThanks;

  /// No description provided for @reportAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'You already reported this'**
  String get reportAlreadyExists;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEdit;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get profileLogout;

  /// No description provided for @confirmLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get confirmLogoutTitle;

  /// No description provided for @confirmLogoutMsg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get confirmLogoutMsg;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @myPosts.
  ///
  /// In en, this message translates to:
  /// **'My Posts'**
  String get myPosts;

  /// No description provided for @statsPosts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get statsPosts;

  /// No description provided for @statsLikes.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get statsLikes;

  /// No description provided for @noMyPosts.
  ///
  /// In en, this message translates to:
  /// **'You have no posts yet'**
  String get noMyPosts;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'DELETE ACCOUNT'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone. All your data, posts and comments will be deleted. Continue?'**
  String get deleteAccountConfirm;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password (optional)'**
  String get changePassword;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPasswordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get changesSaved;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalSettings;

  /// No description provided for @appPurpose.
  ///
  /// In en, this message translates to:
  /// **'App purpose'**
  String get appPurpose;

  /// No description provided for @modePeriodTrack.
  ///
  /// In en, this message translates to:
  /// **'Period Tracking'**
  String get modePeriodTrack;

  /// No description provided for @modePeriodTrackDesc.
  ///
  /// In en, this message translates to:
  /// **'Track your menstrual cycle'**
  String get modePeriodTrackDesc;

  /// No description provided for @modePregnancy.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy'**
  String get modePregnancy;

  /// No description provided for @modePregnancyDesc.
  ///
  /// In en, this message translates to:
  /// **'Track your pregnancy'**
  String get modePregnancyDesc;

  /// No description provided for @modeTryConceive.
  ///
  /// In en, this message translates to:
  /// **'Trying to Conceive'**
  String get modeTryConceive;

  /// No description provided for @modeTryConceiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Track fertility windows'**
  String get modeTryConceiveDesc;

  /// No description provided for @notificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSection;

  /// No description provided for @notifCommentOnPost.
  ///
  /// In en, this message translates to:
  /// **'Comment on my post'**
  String get notifCommentOnPost;

  /// No description provided for @notifCommentOnPostDesc.
  ///
  /// In en, this message translates to:
  /// **'Notify me when someone comments on my post'**
  String get notifCommentOnPostDesc;

  /// No description provided for @notifPeriodStart.
  ///
  /// In en, this message translates to:
  /// **'Period started'**
  String get notifPeriodStart;

  /// No description provided for @notifPeriodStartDesc.
  ///
  /// In en, this message translates to:
  /// **'Remind me when my period is due'**
  String get notifPeriodStartDesc;

  /// No description provided for @notifPeriodEnd.
  ///
  /// In en, this message translates to:
  /// **'Period ended'**
  String get notifPeriodEnd;

  /// No description provided for @notifPeriodEndDesc.
  ///
  /// In en, this message translates to:
  /// **'Remind me when my period ends'**
  String get notifPeriodEndDesc;

  /// No description provided for @notifExerciseReminder.
  ///
  /// In en, this message translates to:
  /// **'Exercise reminder'**
  String get notifExerciseReminder;

  /// No description provided for @notifExerciseReminderDesc.
  ///
  /// In en, this message translates to:
  /// **'Twice a week'**
  String get notifExerciseReminderDesc;

  /// No description provided for @themeSection.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeSection;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get themeSystem;

  /// No description provided for @cycleSection.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get cycleSection;

  /// No description provided for @cycleLengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Average cycle length'**
  String get cycleLengthLabel;

  /// No description provided for @periodLengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Period length'**
  String get periodLengthLabel;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  // ── Calendar / Home ─────────────────────────────────────────────────────
  String get calendarColorsTooltip;
  String get legendTitle;
  String get legendSubtitle;
  String get legendPeriodHeavy;
  String get legendPeriodLight;
  String get legendOvulation;
  String get legendFertileHigh;
  String get legendFertileMedium;
  String get legendFertileLow;
  String get legendBlend;
  String get legendDot;
  String get gotIt;
  String get logSymptomBtn;
  String get startPeriodBtn;
  String get endPeriodBtn;
  String get periodStartedSnack;
  String get periodEndedSnack;
  String get conceptionQuestion;
  String get conceptionNatural;
  String get conceptionIUI;
  String get conceptionIVF;

  // ── Calendar grid ────────────────────────────────────────────────────────
  String get satBanner;
  String get satDialogTitle;
  String get satDialogBody;
  String get satDialogSetBtn;
  String get cancelBtn;

  // ── Pregnancy day sheet ──────────────────────────────────────────────────
  String get satBadgeLabel;
  String get dueDateBadgeLabel;
  String get babyDevTitle;
  String get babyZodiacTitle;
  String get satNoteBody;
  String get weekLabel;

  // ── Pregnancy calculator ─────────────────────────────────────────────────
  String get pregnancyCalcTitle;
  String get satInputLabel;
  String get cycleLengthInputLabel;
  String get calculateBtn;
  String get dueDateResult;
  String get pregnancyWeekResult;
  String get detailInfoBtn;

  // ── Baby development card ────────────────────────────────────────────────
  String get babyDevCardTitle;
  String get maternalChangesTitle;
  String get weekPrefix;

  // ── Settings ─────────────────────────────────────────────────────────────
  String get languageSection;
  String get languageTurkish;
  String get languageEnglish;

  // ── Fertility cards ──────────────────────────────────────────────────────
  String get fertilityPrepTitle;
  String get fertilityPrepSubtitle;
  String get fertilityPrepSummary;
  String get pregnancySymptomsTitle;
  String get pregnancySymptomsSubtitle;
  String get pregnancySymptomsSummary;
  String get iuiCardTitle;
  String get iuiCardSubtitle;
  String get iuiCardSummary;
  String get ivfCardTitle;
  String get ivfCardSubtitle;
  String get ivfCardSummary;
  String get detailInfoBtn2;

  // ── Important days card ──────────────────────────────────────────────────
  String get importantDaysTitle;

  // ── Appointments card ────────────────────────────────────────────────────
  String get appointmentsTitle;
  String get noAppointments;
  String get addAppointment;

  // ── Info card ─────────────────────────────────────────────────────────────
  String get selectDayLabel;
  String get okBtn;

  // ── Cycle summary card ────────────────────────────────────────────────────
  String get cycleSummaryTitle;
  String get historyLabel;
  String get yourSummaryLabel;
  String get currentPeriodLabel;
  String get daysUnit;
  String get periodDurationSuffix;
  String get periodStartPrefix;
  String get lastPeriodLabel;
  String get normalPeriodDurationLabel;
  String get normalCycleLengthLabel;
  String get daysAgoSuffix;

  // ── Symptom sheet ─────────────────────────────────────────────────────────
  String get symptomSheetTitle;
  String get symptomSheetHint;
  String get physicalLabel;
  String get emotionalLabel;
  String get saveBtn;
  String get symptomsSavedSnack;
}

extension AppLocalizationsX on AppLocalizations {
  bool get isTurkish => localeName == 'tr';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
