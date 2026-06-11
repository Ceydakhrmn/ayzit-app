// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Ayzit';

  @override
  String get appSubtitle => 'Sigue tu ciclo, comparte y conecta';

  @override
  String get calendarTab => 'Calendario';

  @override
  String get exerciseTab => 'Ejercicio';

  @override
  String get socialTab => 'Social';

  @override
  String get profileTab => 'Perfil';

  @override
  String get loginTitle => 'Bienvenida';

  @override
  String get loginSubtitle => 'Inicia sesión para continuar';

  @override
  String get registerTitle => 'Crear cuenta';

  @override
  String get registerSubtitle => 'Regístrate para unirte a la comunidad';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get confirmPasswordLabel => 'Contraseña (confirmar)';

  @override
  String get usernameLabel => 'Usuario';

  @override
  String get displayNameLabel => 'Nombre visible';

  @override
  String get loginButton => 'INICIAR SESIÓN';

  @override
  String get registerButton => 'REGISTRARSE';

  @override
  String get loginWithGoogle => 'Continuar con Google';

  @override
  String get forgotPassword => 'Olvidé mi contraseña';

  @override
  String get noAccountYet => '¿No tienes cuenta?';

  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta?';

  @override
  String get signUpLink => 'Regístrate';

  @override
  String get signInLink => 'Inicia sesión';

  @override
  String get passwordsDontMatch => 'Las contraseñas no coinciden';

  @override
  String get passwordTooShort => 'Mínimo 6 caracteres';

  @override
  String get emailInvalid => 'Introduce un email válido';

  @override
  String get emailRequired => 'Email requerido';

  @override
  String get passwordRequired => 'Contraseña requerida';

  @override
  String get usernameTaken => 'Ese usuario ya existe';

  @override
  String get usernameInvalid => 'Usuario no válido';

  @override
  String get verifyEmailTitle => 'Verifica tu email';

  @override
  String get verifyEmailSubtitle => 'Casi listo';

  @override
  String get verifyEmailBody => 'Te enviamos un enlace de verificación. Revisa tu bandeja.';

  @override
  String get verifyEmailPolling => 'Continuaremos automáticamente cuando verifiques.';

  @override
  String get verifyEmailSent => 'Email de verificación enviado';

  @override
  String get verifiedButton => 'YA VERIFIQUÉ';

  @override
  String get resendVerification => 'Reenviar email';

  @override
  String get forgotPasswordTitle => 'Olvidé mi contraseña';

  @override
  String get forgotPasswordSubtitle => 'Te enviaremos un enlace de recuperación';

  @override
  String get sendResetLink => 'ENVIAR ENLACE';

  @override
  String get resetLinkSent => 'Enlace enviado';

  @override
  String get backToLogin => 'VOLVER A INICIAR SESIÓN';

  @override
  String get socialLatest => 'Recientes';

  @override
  String get socialPopular => 'Populares';

  @override
  String get newPost => 'Nueva publicación';

  @override
  String get editPost => 'Editar';

  @override
  String get postHint => '¿Qué estás pensando?';

  @override
  String get postAnonymously => 'Publicar en anónimo';

  @override
  String get postAnonymouslyHint => 'Tu usuario no aparecerá';

  @override
  String get share => 'PUBLICAR';

  @override
  String get saveChanges => 'GUARDAR';

  @override
  String get emptyPostError => 'No puedes publicar contenido vacío';

  @override
  String get profanityDetected => 'El contenido infringe las normas';

  @override
  String get noPostsYet => 'Aún no hay publicaciones';

  @override
  String get anonymousUser => 'Anónimo';

  @override
  String get editedLabel => 'editado';

  @override
  String get deletePostTitle => 'Eliminar publicación';

  @override
  String get deletePostConfirm => '¿Seguro que quieres eliminar esta publicación?';

  @override
  String get commentsTitle => 'Comentarios';

  @override
  String get writeComment => 'Escribe un comentario...';

  @override
  String get reply => 'Responder';

  @override
  String replyingTo(String username) {
    return 'Respondiendo a $username';
  }

  @override
  String get noComments => 'Sin comentarios. ¡Sé la primera!';

  @override
  String get deleteCommentTitle => 'Eliminar comentario';

  @override
  String get deleteCommentConfirm => '¿Eliminar este comentario?';

  @override
  String get reportPost => 'Reportar';

  @override
  String get reportTitle => 'Reportar';

  @override
  String get reportReasonHint => 'Selecciona un motivo';

  @override
  String get reportReasonSpam => 'Spam';

  @override
  String get reportReasonHarassment => 'Acoso';

  @override
  String get reportReasonInappropriate => 'Inapropiado';

  @override
  String get reportReasonHate => 'Discurso de odio';

  @override
  String get reportReasonOther => 'Otro';

  @override
  String get reportDescription => 'Descripción (opcional)';

  @override
  String get reportThanks => 'Reporte recibido, gracias';

  @override
  String get reportAlreadyExists => 'Ya has reportado esto';

  @override
  String get profileEdit => 'Editar perfil';

  @override
  String get profileSettings => 'Ajustes';

  @override
  String get profileLogout => 'Cerrar sesión';

  @override
  String get confirmLogoutTitle => 'Cerrar sesión';

  @override
  String get confirmLogoutMsg => '¿Seguro que quieres cerrar sesión?';

  @override
  String get cancelAction => 'Cancelar';

  @override
  String get myPosts => 'Mis publicaciones';

  @override
  String get statsPosts => 'Publicaciones';

  @override
  String get statsLikes => 'Likes';

  @override
  String get noMyPosts => 'Aún no tienes publicaciones';

  @override
  String get dangerZone => 'Zona peligrosa';

  @override
  String get deleteAccount => 'ELIMINAR CUENTA';

  @override
  String get deleteAccountConfirm => 'Esta acción es irreversible. Se eliminarán todos tus datos. ¿Continuar?';

  @override
  String get changePassword => 'Cambiar contraseña (opcional)';

  @override
  String get currentPasswordLabel => 'Contraseña actual';

  @override
  String get newPasswordLabel => 'Nueva contraseña';

  @override
  String get changesSaved => 'Cambios guardados';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get generalSettings => 'General';

  @override
  String get appPurpose => 'Propósito de la app';

  @override
  String get modePeriodTrack => 'Seguimiento del ciclo';

  @override
  String get modePeriodTrackDesc => 'Sigue tu ciclo menstrual';

  @override
  String get modePregnancy => 'Embarazo';

  @override
  String get modePregnancyDesc => 'Sigue tu embarazo';

  @override
  String get modeTryConceive => 'Buscando embarazo';

  @override
  String get modeTryConceiveDesc => 'Sigue tus días fértiles';

  @override
  String get notificationsSection => 'Notificaciones';

  @override
  String get notifCommentOnPost => 'Comentario en mi publicación';

  @override
  String get notifCommentOnPostDesc => 'Avísame cuando comenten mi publicación';

  @override
  String get notifPeriodStart => 'Inicio del período';

  @override
  String get notifPeriodStartDesc => 'Recuérdame cuando llegue mi período';

  @override
  String get notifPeriodEnd => 'Fin del período';

  @override
  String get notifPeriodEndDesc => 'Recuérdame el último día';

  @override
  String get notifExerciseReminder => 'Recordatorio de ejercicio';

  @override
  String get notifExerciseReminderDesc => 'Dos veces por semana';

  @override
  String get themeSection => 'Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get cycleSection => 'Ciclo';

  @override
  String get cycleLengthLabel => 'Duración media del ciclo';

  @override
  String get periodLengthLabel => 'Duración del período';

  @override
  String get errorGeneric => 'Algo salió mal';

  @override
  String get tryAgain => 'Reintentar';

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
