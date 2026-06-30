// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Ayzit';

  @override
  String get appSubtitle => 'Suis ton cycle, partage et connecte-toi';

  @override
  String get calendarTab => 'Calendrier';

  @override
  String get exerciseTab => 'Exercice';

  @override
  String get socialTab => 'Social';

  @override
  String get profileTab => 'Profil';

  @override
  String get loginTitle => 'Bienvenue';

  @override
  String get loginSubtitle => 'Connecte-toi pour continuer';

  @override
  String get registerTitle => 'Créer un compte';

  @override
  String get registerSubtitle => 'Inscris-toi pour rejoindre la communauté';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get confirmPasswordLabel => 'Mot de passe (confirmer)';

  @override
  String get usernameLabel => 'Nom d\'utilisateur';

  @override
  String get displayNameLabel => 'Nom affiché';

  @override
  String get loginButton => 'CONNEXION';

  @override
  String get registerButton => 'S\'INSCRIRE';

  @override
  String get loginWithGoogle => 'Continuer avec Google';

  @override
  String get forgotPassword => 'Mot de passe oublié';

  @override
  String get noAccountYet => 'Pas de compte ?';

  @override
  String get alreadyHaveAccount => 'Déjà un compte ?';

  @override
  String get signUpLink => 'S\'inscrire';

  @override
  String get signInLink => 'Se connecter';

  @override
  String get passwordsDontMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get passwordTooShort => 'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get emailInvalid => 'Entre un email valide';

  @override
  String get emailRequired => 'Email requis';

  @override
  String get passwordRequired => 'Mot de passe requis';

  @override
  String get usernameTaken => 'Ce nom est déjà pris';

  @override
  String get usernameInvalid => 'Nom invalide';

  @override
  String get verifyEmailTitle => 'Vérifie ton email';

  @override
  String get verifyEmailSubtitle => 'Presque terminé';

  @override
  String get verifyEmailBody => 'Nous avons envoyé un lien de vérification à ton email.';

  @override
  String get verifyEmailPolling => 'Tu continueras automatiquement une fois vérifié.';

  @override
  String get verifyEmailSent => 'Email de vérification envoyé';

  @override
  String get verifiedButton => 'J\'AI VÉRIFIÉ';

  @override
  String get resendVerification => 'Renvoyer l\'email';

  @override
  String get forgotPasswordTitle => 'Mot de passe oublié';

  @override
  String get forgotPasswordSubtitle => 'On t\'envoie un lien de réinitialisation';

  @override
  String get sendResetLink => 'ENVOYER LE LIEN';

  @override
  String get resetLinkSent => 'Lien envoyé';

  @override
  String get backToLogin => 'RETOUR À LA CONNEXION';

  @override
  String get socialLatest => 'Récents';

  @override
  String get socialPopular => 'Populaires';

  @override
  String get newPost => 'Nouveau post';

  @override
  String get editPost => 'Modifier';

  @override
  String get postHint => 'Qu\'as-tu en tête ?';

  @override
  String get postAnonymously => 'Publier anonymement';

  @override
  String get postAnonymouslyHint => 'Ton nom n\'apparaîtra pas';

  @override
  String get share => 'PUBLIER';

  @override
  String get saveChanges => 'ENREGISTRER';

  @override
  String get emptyPostError => 'Le post ne peut pas être vide';

  @override
  String get profanityDetected => 'Contenu contraire aux règles';

  @override
  String get noPostsYet => 'Aucun post pour le moment';

  @override
  String get anonymousUser => 'Anonyme';

  @override
  String get editedLabel => 'modifié';

  @override
  String get deletePostTitle => 'Supprimer le post';

  @override
  String get deletePostConfirm => 'Es-tu sûr de vouloir supprimer ce post ?';

  @override
  String get commentsTitle => 'Commentaires';

  @override
  String get writeComment => 'Écris un commentaire...';

  @override
  String get reply => 'Répondre';

  @override
  String replyingTo(String username) {
    return 'Réponse à $username';
  }

  @override
  String get noComments => 'Aucun commentaire. Sois le premier !';

  @override
  String get deleteCommentTitle => 'Supprimer le commentaire';

  @override
  String get deleteCommentConfirm => 'Supprimer ce commentaire ?';

  @override
  String get reportPost => 'Signaler';

  @override
  String get reportTitle => 'Signaler';

  @override
  String get reportReasonHint => 'Choisis un motif';

  @override
  String get reportReasonSpam => 'Spam';

  @override
  String get reportReasonHarassment => 'Harcèlement';

  @override
  String get reportReasonInappropriate => 'Inapproprié';

  @override
  String get reportReasonHate => 'Discours haineux';

  @override
  String get reportReasonOther => 'Autre';

  @override
  String get reportDescription => 'Description (optionnel)';

  @override
  String get reportThanks => 'Signalement reçu, merci';

  @override
  String get reportAlreadyExists => 'Tu l\'as déjà signalé';

  @override
  String get profileEdit => 'Modifier le profil';

  @override
  String get profileSettings => 'Paramètres';

  @override
  String get profileLogout => 'Déconnexion';

  @override
  String get confirmLogoutTitle => 'Déconnexion';

  @override
  String get confirmLogoutMsg => 'Veux-tu vraiment te déconnecter ?';

  @override
  String get cancelAction => 'Annuler';

  @override
  String get myPosts => 'Mes posts';

  @override
  String get statsPosts => 'Posts';

  @override
  String get statsLikes => 'Likes';

  @override
  String get noMyPosts => 'Tu n\'as pas encore de posts';

  @override
  String get dangerZone => 'Zone dangereuse';

  @override
  String get deleteAccount => 'SUPPRIMER LE COMPTE';

  @override
  String get deleteAccountConfirm => 'Cette action est irréversible. Toutes tes données seront supprimées. Continuer ?';

  @override
  String get changePassword => 'Changer de mot de passe (optionnel)';

  @override
  String get currentPasswordLabel => 'Mot de passe actuel';

  @override
  String get newPasswordLabel => 'Nouveau mot de passe';

  @override
  String get changesSaved => 'Modifications enregistrées';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get generalSettings => 'Général';

  @override
  String get appPurpose => 'Objectif de l\'app';

  @override
  String get modePeriodTrack => 'Suivi du cycle';

  @override
  String get modePeriodTrackDesc => 'Suis ton cycle menstruel';

  @override
  String get modePregnancy => 'Grossesse';

  @override
  String get modePregnancyDesc => 'Suis ta grossesse';

  @override
  String get modeTryConceive => 'Concevoir';

  @override
  String get modeTryConceiveDesc => 'Suis ta fenêtre de fertilité';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get notifCommentOnPost => 'Commentaire sur mon post';

  @override
  String get notifCommentOnPostDesc => 'Me notifier quand quelqu\'un commente';

  @override
  String get notifPeriodStart => 'Début des règles';

  @override
  String get notifPeriodStartDesc => 'Me rappeler le jour de mes règles';

  @override
  String get notifPeriodEnd => 'Fin des règles';

  @override
  String get notifPeriodEndDesc => 'Me rappeler la fin';

  @override
  String get notifExerciseReminder => 'Rappel d\'exercice';

  @override
  String get notifExerciseReminderDesc => 'Deux fois par semaine';

  @override
  String get themeSection => 'Thème';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystem => 'Système';

  @override
  String get cycleSection => 'Cycle';

  @override
  String get cycleLengthLabel => 'Durée moyenne du cycle';

  @override
  String get periodLengthLabel => 'Durée des règles';

  @override
  String get errorGeneric => 'Une erreur est survenue';

  @override
  String get tryAgain => 'Réessayer';

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
