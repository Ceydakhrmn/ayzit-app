// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Ayzit';

  @override
  String get btnContinue => 'DEVAM ET';

  @override
  String get appSubtitle => 'Takip et, paylaş ve bağlan';

  @override
  String get calendarTab => 'Takvim';

  @override
  String get exerciseTab => 'Egzersiz';

  @override
  String get socialTab => 'Sosyal';

  @override
  String get profileTab => 'Profil';

  @override
  String get loginTitle => 'Hoş geldin';

  @override
  String get loginSubtitle => 'Devam etmek için giriş yap';

  @override
  String get registerTitle => 'Hesap oluştur';

  @override
  String get registerSubtitle => 'Topluluğa katılmak için kayıt ol';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Şifre';

  @override
  String get confirmPasswordLabel => 'Şifre (tekrar)';

  @override
  String get usernameLabel => 'Kullanıcı adı';

  @override
  String get displayNameLabel => 'İsim (görünen ad)';

  @override
  String get loginButton => 'GİRİŞ YAP';

  @override
  String get registerButton => 'KAYIT OL';

  @override
  String get loginWithGoogle => 'Google ile devam et';

  @override
  String get forgotPassword => 'Şifremi unuttum';

  @override
  String get noAccountYet => 'Hesabın yok mu?';

  @override
  String get alreadyHaveAccount => 'Zaten hesabın var mı?';

  @override
  String get signUpLink => 'Kayıt ol';

  @override
  String get signInLink => 'Giriş yap';

  @override
  String get passwordsDontMatch => 'Şifreler eşleşmiyor';

  @override
  String get passwordTooShort => 'Şifre en az 6 karakter olmalı';

  @override
  String get emailInvalid => 'Geçerli bir email girin';

  @override
  String get emailRequired => 'Email gerekli';

  @override
  String get passwordRequired => 'Şifre gerekli';

  @override
  String get usernameTaken => 'Bu kullanıcı adı alınmış';

  @override
  String get usernameInvalid => 'Geçersiz kullanıcı adı';

  @override
  String get verifyEmailTitle => 'Email doğrulama';

  @override
  String get verifyEmailSubtitle => 'Kayıt tamamlandı, sadece bir adım kaldı';

  @override
  String get verifyEmailBody => 'Sana bir doğrulama linki gönderdik. Email kutunu kontrol et ve linke tıkla.';

  @override
  String get verifyEmailPolling => 'Doğrulama tamamlandığında otomatik olarak devam edilecek.';

  @override
  String get verifyEmailSent => 'Doğrulama e-postası gönderildi';

  @override
  String get verifiedButton => 'DOĞRULADIM';

  @override
  String get resendVerification => 'Maili tekrar gönder';

  @override
  String get forgotPasswordTitle => 'Şifremi unuttum';

  @override
  String get forgotPasswordSubtitle => 'Sana sıfırlama linki gönderelim';

  @override
  String get sendResetLink => 'SIFIRLAMA LİNKİ GÖNDER';

  @override
  String get resetLinkSent => 'Sıfırlama linki gönderildi';

  @override
  String get backToLogin => 'GİRİŞE DÖN';

  @override
  String get socialLatest => 'En Yeni';

  @override
  String get socialPopular => 'Popüler';

  @override
  String get newPost => 'Yeni Paylaşım';

  @override
  String get editPost => 'Postu Düzenle';

  @override
  String get postHint => 'Ne düşünüyorsun?';

  @override
  String get postAnonymously => 'Anonim paylaş';

  @override
  String get postAnonymouslyHint => 'Kullanıcı adın feed\'de gözükmez';

  @override
  String get share => 'PAYLAŞ';

  @override
  String get saveChanges => 'KAYDET';

  @override
  String get emptyPostError => 'Boş post gönderemezsin';

  @override
  String get profanityDetected => 'İçerik topluluk kurallarına uygun değil';

  @override
  String get noPostsYet => 'Henüz paylaşım yok';

  @override
  String get anonymousUser => 'Anonim';

  @override
  String get editedLabel => 'düzenlendi';

  @override
  String get deletePostTitle => 'Postu Sil';

  @override
  String get deletePostConfirm => 'Bu paylaşımı silmek istediğine emin misin?';

  @override
  String get commentsTitle => 'Yorumlar';

  @override
  String get writeComment => 'Yorum yaz...';

  @override
  String get reply => 'Yanıtla';

  @override
  String replyingTo(String username) {
    return 'Yanıt: $username';
  }

  @override
  String get noComments => 'Henüz yorum yok. İlk sen yaz!';

  @override
  String get deleteCommentTitle => 'Yorumu Sil';

  @override
  String get deleteCommentConfirm => 'Bu yorumu silmek istediğine emin misin?';

  @override
  String get reportPost => 'Şikayet Et';

  @override
  String get reportTitle => 'Şikayet Et';

  @override
  String get reportReasonHint => 'Lütfen sebebi seç';

  @override
  String get reportReasonSpam => 'Spam';

  @override
  String get reportReasonHarassment => 'Taciz';

  @override
  String get reportReasonInappropriate => 'Uygunsuz içerik';

  @override
  String get reportReasonHate => 'Nefret söylemi';

  @override
  String get reportReasonOther => 'Diğer';

  @override
  String get reportDescription => 'Açıklama (opsiyonel)';

  @override
  String get reportThanks => 'Şikayetin alındı, teşekkürler';

  @override
  String get reportAlreadyExists => 'Bunu zaten şikayet etmişsin';

  @override
  String get profileEdit => 'Profili Düzenle';

  @override
  String get profileSettings => 'Ayarlar';

  @override
  String get profileLogout => 'Çıkış Yap';

  @override
  String get confirmLogoutTitle => 'Çıkış Yap';

  @override
  String get confirmLogoutMsg => 'Oturumu kapatmak istediğinden emin misin?';

  @override
  String get cancelAction => 'Vazgeç';

  @override
  String get myPosts => 'Paylaşımlarım';

  @override
  String get statsPosts => 'Paylaşım';

  @override
  String get statsLikes => 'Beğeni';

  @override
  String get noMyPosts => 'Henüz paylaşımın yok';

  @override
  String get dangerZone => 'Tehlikeli Bölge';

  @override
  String get deleteAccount => 'HESABI SİL';

  @override
  String get deleteAccountConfirm => 'Bu işlem geri alınamaz. Tüm verilerin, paylaşımların ve yorumların silinecek. Emin misin?';

  @override
  String get changePassword => 'Şifreyi değiştir (opsiyonel)';

  @override
  String get currentPasswordLabel => 'Mevcut şifre';

  @override
  String get newPasswordLabel => 'Yeni şifre';

  @override
  String get changesSaved => 'Değişiklikler kaydedildi';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get generalSettings => 'Genel Ayarlar';

  @override
  String get appPurpose => 'Uygulama amacı';

  @override
  String get modePeriodTrack => 'Regl Takip';

  @override
  String get modePeriodTrackDesc => 'Adet takibinizi yapın';

  @override
  String get modePregnancy => 'Hamile Takip';

  @override
  String get modePregnancyDesc => 'Hamilelik sürecinizi takip edin';

  @override
  String get modeTryConceive => 'Ovülasyon & Hamile Kalma';

  @override
  String get modeTryConceiveDesc => 'Ovülasyon takibi ve doğurganlık penceresi';

  @override
  String get notificationsSection => 'Bildirimler';

  @override
  String get notifCommentOnPost => 'Postuma yorum geldiğinde';

  @override
  String get notifCommentOnPostDesc => 'Paylaşımlarına yorum geldiğinde bildirim al';

  @override
  String get notifPeriodStart => 'Regl başladı';

  @override
  String get notifPeriodStartDesc => 'Regl günün geldiğinde hatırlat';

  @override
  String get notifPeriodEnd => 'Regl bitti';

  @override
  String get notifPeriodEndDesc => 'Regl bitiş günü hatırlat';

  @override
  String get notifExerciseReminder => 'Egzersiz hatırlatıcısı';

  @override
  String get notifExerciseReminderDesc => 'Haftada 2 kez egzersiz zamanı';

  @override
  String get themeSection => 'Tema';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get themeSystem => 'Sistemi takip et';

  @override
  String get cycleSection => 'Döngü';

  @override
  String get cycleLengthLabel => 'Ortalama adet uzunluğu';

  @override
  String get periodLengthLabel => 'Regl süresi';

  @override
  String get errorGeneric => 'Bir hata oluştu';

  @override
  String get tryAgain => 'Tekrar dene';

  // ── Calendar / Home ─────────────────────────────────────────────────────
  @override
  String get calendarColorsTooltip => 'Takvim Renkleri';

  @override
  String get legendTitle => 'Sanırım yardıma ihtiyacın var.';

  @override
  String get legendSubtitle => 'Renkler dönemleri gösterir. Ben de sana bu dönemlere göre tavsiyeler veririm ;)';

  @override
  String get legendPeriodHeavy => 'Regl dönemi (yoğun).';

  @override
  String get legendPeriodLight => 'Regl dönemi (hafif).';

  @override
  String get legendOvulation => 'Ovulasyon günü.';

  @override
  String get legendFertileHigh => 'Doğurganlık — en yüksek.';

  @override
  String get legendFertileMedium => 'Doğurganlık — orta.';

  @override
  String get legendFertileLow => 'Doğurganlık — düşük.';

  @override
  String get legendBlend => 'Soluk renkli olanlar benim tahminimdir.';

  @override
  String get legendDot => 'Takvime bilgi girdiğini gösterir.';

  @override
  String get gotIt => 'ANLADIM';

  @override
  String get logSymptomBtn => 'BELİRTİ GİR';

  @override
  String get startPeriodBtn => 'REGL BAŞLAT';

  @override
  String get endPeriodBtn => 'REGL BİTİR';

  @override
  String get periodStartedSnack => 'Regl başlatıldı!';

  @override
  String get periodEndedSnack => 'Regl bitirildi!';

  @override
  String get conceptionQuestion => 'Nasıl hamile kalmayı planlıyorsunuz?';

  @override
  String get conceptionNatural => 'Doğal';

  @override
  String get conceptionIUI => 'Aşılama';

  @override
  String get conceptionIVF => 'Tüp Bebek';

  // ── Calendar grid ────────────────────────────────────────────────────────
  @override
  String get satBanner => 'Son adet tarihinizi seçmek için takvimde bir güne dokunun.';

  @override
  String get satDialogTitle => 'Son Adet Tarihi';

  @override
  String get satDialogBody => 'tarihini gebelik başlangıcı (SAT) olarak ayarlamak istiyor musunuz?\n\nTahmini doğum tarihi otomatik hesaplanacak.';

  @override
  String get satDialogSetBtn => 'Ayarla';

  @override
  String get cancelBtn => 'İptal';

  // ── Pregnancy day sheet ──────────────────────────────────────────────────
  @override
  String get satBadgeLabel => 'Son Adet Tarihi (SAT)';

  @override
  String get dueDateBadgeLabel => 'Tahmini Doğum Tarihi';

  @override
  String get babyDevTitle => 'Bebek Gelişimi';

  @override
  String get babyZodiacTitle => 'Bebeğinin Burcu';

  @override
  String get satNoteBody => 'Bu tarih, gebeliğinizin başlangıç noktası (Son Adet Tarihi) olarak ayarlanmış. Tüm hafta hesaplamaları bu tarihten itibaren yapılır.';

  @override
  String get weekLabel => '. Hafta';

  // ── Pregnancy calculator ─────────────────────────────────────────────────
  @override
  String get pregnancyCalcTitle => 'Gebelik Hesaplayıcı';

  @override
  String get satInputLabel => 'Son Adet Tarihi (SAT)';

  @override
  String get cycleLengthInputLabel => 'Ortalama Döngü Uzunluğu';

  @override
  String get calculateBtn => 'Hesapla';

  @override
  String get dueDateResult => 'Tahmini Doğum Tarihi';

  @override
  String get pregnancyWeekResult => 'Gebelik Haftası';

  @override
  String get detailInfoBtn => '📖 Detaylı Bilgi';

  // ── Baby development card ────────────────────────────────────────────────
  @override
  String get babyDevCardTitle => 'Bebeğin Gelişimi';

  @override
  String get maternalChangesTitle => 'Annedeki Değişimler';

  @override
  String get weekPrefix => '. Hafta';

  // ── Settings ─────────────────────────────────────────────────────────────
  @override
  String get languageSection => 'Dil';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'İngilizce';

  // ── Fertility cards ──────────────────────────────────────────────────────
  @override
  String get fertilityPrepTitle => 'Gebeliğe Hazırlık';

  @override
  String get fertilityPrepSubtitle => 'Sağlıklı gebelik için 3 ay önceden başlayın';

  @override
  String get fertilityPrepSummary => 'Folik asit takviyesi, sağlık kontrolü, beslenme ve yaşam tarzı değişiklikleri ile sağlıklı bir gebeliğe hazırlanın.';

  @override
  String get pregnancySymptomsTitle => 'Hamilelik Belirtileri';

  @override
  String get pregnancySymptomsSubtitle => 'Erken belirtiler ve tanı yöntemleri';

  @override
  String get pregnancySymptomsSummary => 'Adet gecikmesi, meme hassasiyeti, bulantı ve daha fazlası. Ne zaman test yapmalı, ne zaman doktora gidilmeli?';

  @override
  String get iuiCardTitle => 'Aşılama Tedavisi (IUI)';

  @override
  String get iuiCardSubtitle => 'Tüp bebek öncesi ilk basamak tedavi';

  @override
  String get iuiCardSummary => 'Spermin rahim içine yerleştirildiği, ağrısız ve anestezi gerektirmeyen yardımcı üreme yöntemi. Başarı oranı %10–30.';

  @override
  String get ivfCardTitle => 'Tüp Bebek Tedavisi (IVF)';

  @override
  String get ivfCardSubtitle => 'Yüksek başarı oranlı yardımcı üreme yöntemi';

  @override
  String get ivfCardSummary => 'Yumurta ve spermin laboratuvarda döllenerek rahme yerleştirilmesi. 35 yaş altında %35–45 başarı oranı.';

  @override
  String get detailInfoBtn2 => 'Detaylı Bilgi';

  // ── Important days card ──────────────────────────────────────────────────
  @override
  String get importantDaysTitle => 'Önemli Günler';

  // ── Appointments card ────────────────────────────────────────────────────
  @override
  String get appointmentsTitle => 'Randevular';

  @override
  String get noAppointments => 'Randevu yok';

  @override
  String get addAppointment => 'Randevu Ekle';

  // ── Info card ─────────────────────────────────────────────────────────────
  @override String get selectDayLabel => 'Bir gün seçin';
  @override String get okBtn => 'Tamam';

  // ── Cycle summary card ────────────────────────────────────────────────────
  @override String get cycleSummaryTitle => 'Genel Özet';
  @override String get historyLabel => 'Geçmiş';
  @override String get yourSummaryLabel => 'Özetin';
  @override String get currentPeriodLabel => 'Şu Anki Periyot';
  @override String get daysUnit => 'Gün';
  @override String get periodDurationSuffix => 'Günlük Süre';
  @override String get periodStartPrefix => 'Başlangıç';
  @override String get lastPeriodLabel => 'Son Adet Dönemi';
  @override String get normalPeriodDurationLabel => 'Normal Adet Süresi';
  @override String get normalCycleLengthLabel => 'Normal Adet Uzunluğu';
  @override String get daysAgoSuffix => 'Gün Önce';

  // ── Symptom sheet ─────────────────────────────────────────────────────────
  @override String get symptomSheetTitle => 'Belirti Gir';
  @override String get symptomSheetHint => 'Bugün hissettiğin belirtileri seç';
  @override String get physicalLabel => 'Fiziksel';
  @override String get emotionalLabel => 'Duygusal';
  @override String get saveBtn => 'KAYDET';
  @override String get symptomsSavedSnack => 'Belirtiler kaydedildi!';

  // ── Common action buttons ─────────────────────────────────────────────────
  @override String get deleteBtn => 'Sil';
  @override String get editBtn => 'Düzenle';
  @override String get reportBtn => 'Şikayet Et';
  @override String get logoutBtn => 'Çıkış Yap';
  @override String get profileLabel => 'Profil';
  @override String get settingsLabel => 'Ayarlar';
  @override String get editProfileLabel => 'Profili Düzenle';
  @override String get myPostsLabel => 'Paylaşımlarım';
  @override String get dismissBtn => 'Vazgeç';
}
