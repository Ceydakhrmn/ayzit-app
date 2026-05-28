// =============================================
// screens/privacy_policy_screen.dart
// Gizlilik Politikası & Kullanım Koşulları
// TR / EN — isTurkish kontrolüyle otomatik dil
// =============================================

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final bool showTerms;
  const PrivacyPolicyScreen({super.key, this.showTerms = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEn = !l10n.isTurkish;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          showTerms
              ? (isEn ? 'Terms of Use' : 'Kullanım Koşulları')
              : (isEn ? 'Privacy Policy' : 'Gizlilik Politikası'),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
        child: showTerms
            ? _TermsContent(isEn: isEn, cs: cs)
            : _PrivacyContent(isEn: isEn, cs: cs),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gizlilik Politikası
// ─────────────────────────────────────────────────────────────────────────────

class _PrivacyContent extends StatelessWidget {
  final bool isEn;
  final ColorScheme cs;
  const _PrivacyContent({required this.isEn, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _updated(isEn ? 'Last updated: May 2025' : 'Son güncelleme: Mayıs 2025', cs),
        _h1(isEn ? 'Privacy Policy' : 'Gizlilik Politikası', cs),
        _p(
          isEn
              ? 'Lunora ("we", "us", "our") is committed to protecting your personal information. This Privacy Policy explains what data we collect, how we use it, and your rights regarding your information.'
              : 'Lunora olarak kişisel bilgilerinizi korumayı taahhüt ediyoruz. Bu Gizlilik Politikası, hangi verileri topladığımızı, nasıl kullandığımızı ve haklarınızı açıklar.',
          cs,
        ),

        _h2(isEn ? '1. Data We Collect' : '1. Topladığımız Veriler', cs),
        _p(
          isEn
              ? 'We collect the following categories of information:'
              : 'Aşağıdaki kategorilerde bilgi toplamaktayız:',
          cs,
        ),
        _bullet(isEn
            ? 'Account data: email address, username, display name, profile photo seed'
            : 'Hesap verisi: e-posta adresi, kullanıcı adı, görünen ad, profil fotoğrafı tohumu', cs),
        _bullet(isEn
            ? 'Health data: menstrual cycle dates, period start/end, cycle length, symptoms, mood notes'
            : 'Sağlık verisi: adet döngüsü tarihleri, regl başlangıç/bitiş, döngü uzunluğu, belirtiler, ruh hali notları', cs),
        _bullet(isEn
            ? 'Pregnancy data: last menstrual period date, pregnancy-related tracking information'
            : 'Hamilelik verisi: son adet tarihi, hamilelikle ilgili takip bilgileri', cs),
        _bullet(isEn
            ? 'Social content: posts, comments, likes you create within the app'
            : 'Sosyal içerik: uygulama içinde oluşturduğunuz paylaşımlar, yorumlar, beğeniler', cs),
        _bullet(isEn
            ? 'Device data: anonymous usage analytics via Firebase Analytics'
            : 'Cihaz verisi: Firebase Analytics aracılığıyla anonim kullanım analitikleri', cs),

        _h2(isEn ? '2. How We Use Your Data' : '2. Verilerinizi Nasıl Kullanıyoruz', cs),
        _bullet(isEn
            ? 'To provide and improve the Lunora app features'
            : 'Lunora uygulama özelliklerini sunmak ve geliştirmek için', cs),
        _bullet(isEn
            ? 'To calculate cycle predictions and pregnancy tracking'
            : 'Döngü tahminleri ve hamilelik takibini hesaplamak için', cs),
        _bullet(isEn
            ? 'To power the social community features'
            : 'Sosyal topluluk özelliklerini çalıştırmak için', cs),
        _bullet(isEn
            ? 'To send you appointment reminders and relevant notifications'
            : 'Randevu hatırlatmaları ve ilgili bildirimler göndermek için', cs),
        _bullet(isEn
            ? 'We do NOT sell your data to third parties'
            : 'Verilerinizi üçüncü taraflara SATMIYORUZ', cs),

        _h2(isEn ? '3. Third-Party Services' : '3. Üçüncü Taraf Hizmetler', cs),
        _p(
          isEn
              ? 'Lunora uses the following third-party services, each governed by their own privacy policies:'
              : 'Lunora aşağıdaki üçüncü taraf hizmetleri kullanmaktadır; her biri kendi gizlilik politikasına tabidir:',
          cs,
        ),
        _bullet('Firebase (Google) — Authentication, Firestore, Analytics, Crashlytics', cs),
        _bullet('Google Sign-In — OAuth authentication', cs),

        _h2(isEn ? '4. Data Security' : '4. Veri Güvenliği', cs),
        _p(
          isEn
              ? 'Your data is stored on Google Firebase servers with industry-standard security. Access is protected by authentication and Firestore security rules. Health data is never shared with other users unless you explicitly post it.'
              : 'Verileriniz, endüstri standardı güvenlik önlemleriyle Google Firebase sunucularında depolanmaktadır. Erişim, kimlik doğrulama ve Firestore güvenlik kurallarıyla korunmaktadır. Sağlık verileri, siz açıkça paylaşmadıkça diğer kullanıcılarla paylaşılmaz.',
          cs,
        ),

        _h2(isEn ? '5. Your Rights' : '5. Haklarınız', cs),
        _bullet(isEn ? 'Access your data at any time through the app' : 'Uygulama üzerinden verilerinize istediğiniz zaman erişin', cs),
        _bullet(isEn ? 'Delete your account and all associated data via Settings → Edit Profile → Delete Account' : 'Ayarlar → Profili Düzenle → Hesabı Sil yoluyla hesabınızı ve tüm ilişkili verileri silin', cs),
        _bullet(isEn ? 'Export or correct your data by contacting us' : 'Bizimle iletişime geçerek verilerinizi dışa aktarın veya düzeltin', cs),

        _h2(isEn ? '6. Children\'s Privacy' : '6. Çocukların Gizliliği', cs),
        _p(
          isEn
              ? 'Lunora is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13.'
              : 'Lunora, 13 yaşın altındaki çocuklar için tasarlanmamıştır. 13 yaşın altındaki çocuklardan bilerek kişisel bilgi toplamıyoruz.',
          cs,
        ),

        _h2(isEn ? '7. Contact Us' : '7. İletişim', cs),
        _p(
          isEn
              ? 'If you have questions about this Privacy Policy or your data, please contact us at:\n\nsupport@lunora.app'
              : 'Bu Gizlilik Politikası veya verileriniz hakkında sorularınız için bize ulaşın:\n\nsupport@lunora.app',
          cs,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Kullanım Koşulları
// ─────────────────────────────────────────────────────────────────────────────

class _TermsContent extends StatelessWidget {
  final bool isEn;
  final ColorScheme cs;
  const _TermsContent({required this.isEn, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _updated(isEn ? 'Last updated: May 2025' : 'Son güncelleme: Mayıs 2025', cs),
        _h1(isEn ? 'Terms of Use' : 'Kullanım Koşulları', cs),
        _p(
          isEn
              ? 'By downloading or using Lunora, you agree to these Terms of Use. Please read them carefully.'
              : 'Lunora\'yı indirerek veya kullanarak bu Kullanım Koşulları\'nı kabul etmiş sayılırsınız. Lütfen dikkatlice okuyun.',
          cs,
        ),

        _h2(isEn ? '1. Use of the App' : '1. Uygulamanın Kullanımı', cs),
        _bullet(isEn ? 'You must be at least 13 years old to use Lunora' : 'Lunora\'yı kullanmak için en az 13 yaşında olmanız gerekir', cs),
        _bullet(isEn ? 'You are responsible for maintaining the security of your account' : 'Hesabınızın güvenliğini korumak sizin sorumluluğunuzdadır', cs),
        _bullet(isEn ? 'You agree not to use the app for any illegal or harmful purpose' : 'Uygulamayı yasadışı veya zararlı amaçlarla kullanmamayı kabul ediyorsunuz', cs),

        _h2(isEn ? '2. Health Information Disclaimer' : '2. Sağlık Bilgisi Sorumluluk Reddi', cs),
        _p(
          isEn
              ? 'Lunora provides general health tracking and informational content only. The app is NOT a medical device and does NOT provide medical advice. Always consult a qualified healthcare professional for medical decisions.'
              : 'Lunora yalnızca genel sağlık takibi ve bilgilendirici içerik sunar. Uygulama tıbbi bir cihaz DEĞİLDİR ve tıbbi tavsiye VERMEZ. Tıbbi kararlar için her zaman nitelikli bir sağlık uzmanına danışın.',
          cs,
        ),

        _h2(isEn ? '3. Community Guidelines' : '3. Topluluk Kuralları', cs),
        _p(isEn ? 'When using social features, you agree NOT to post:' : 'Sosyal özellikleri kullanırken şunları paylaşmamayı kabul ediyorsunuz:', cs),
        _bullet(isEn ? 'Offensive, hateful, or discriminatory content' : 'Hakaret içeren, nefret dolu veya ayrımcı içerik', cs),
        _bullet(isEn ? 'Personal or private information of others' : 'Başkalarının kişisel veya özel bilgileri', cs),
        _bullet(isEn ? 'Spam or commercial advertising' : 'Spam veya ticari reklamlar', cs),
        _bullet(isEn ? 'Medical misinformation' : 'Tıbbi yanlış bilgi', cs),

        _h2(isEn ? '4. Intellectual Property' : '4. Fikri Mülkiyet', cs),
        _p(
          isEn
              ? 'All content, design, and code in Lunora is owned by or licensed to us. You may not copy, modify, or distribute the app without permission.'
              : 'Lunora\'daki tüm içerik, tasarım ve kod bize aittir veya lisanslıdır. İzin almadan uygulamayı kopyalayamaz, değiştiremez veya dağıtamazsınız.',
          cs,
        ),

        _h2(isEn ? '5. Limitation of Liability' : '5. Sorumluluk Sınırlaması', cs),
        _p(
          isEn
              ? 'Lunora is provided "as is". We are not liable for any damages arising from your use of the app, including any health decisions made based on app content.'
              : 'Lunora "olduğu gibi" sunulmaktadır. Sağlık kararları da dahil olmak üzere uygulamanın kullanımından doğan zararlardan sorumlu değiliz.',
          cs,
        ),

        _h2(isEn ? '6. Changes to Terms' : '6. Koşullardaki Değişiklikler', cs),
        _p(
          isEn
              ? 'We may update these Terms from time to time. Continued use of the app after changes constitutes acceptance of the new Terms.'
              : 'Bu Koşulları zaman zaman güncelleyebiliriz. Değişikliklerden sonra uygulamayı kullanmaya devam etmek yeni Koşulları kabul ettiğiniz anlamına gelir.',
          cs,
        ),

        _h2(isEn ? '7. Contact' : '7. İletişim', cs),
        _p('support@lunora.app', cs),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Yardımcı widget'lar
// ─────────────────────────────────────────────────────────────────────────────

Widget _updated(String text, ColorScheme cs) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: cs.onSurface.withValues(alpha: 0.4),
          fontStyle: FontStyle.italic,
        ),
      ),
    );

Widget _h1(String text, ColorScheme cs) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: cs.onSurface,
        ),
      ),
    );

Widget _h2(String text, ColorScheme cs) => Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: Color(0xFF7C3AED),
        ),
      ),
    );

Widget _p(String text, ColorScheme cs) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.5,
          height: 1.6,
          color: cs.onSurface.withValues(alpha: 0.8),
        ),
      ),
    );

Widget _bullet(String text, ColorScheme cs) => Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7, right: 8),
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF7C3AED),
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: cs.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
