// =============================================
// screens/auth/verify_email_screen.dart
// Shown when a user is logged in but hasn't verified their email yet.
// Periodically polls Firebase to detect verification and advances.
// =============================================

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import 'auth_scaffold.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _pollTimer;
  bool _canResend = true;
  Timer? _cooldownTimer;
  int _cooldownSec = 0;
  String? _error;
  String? _info;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer =
        Timer.periodic(const Duration(seconds: 4), (_) => _checkVerified());
  }

  Future<void> _checkVerified() async {
    final auth = context.read<AuthProvider>();
    try {
      await auth.refreshVerification();
    } catch (_) {}
    if (mounted && auth.status == AuthStatus.authenticated) {
      _pollTimer?.cancel();
    }
  }

  Future<void> _resend() async {
    final isEn = !AppLocalizations.of(context)!.isTurkish;
    setState(() {
      _error = null;
      _info = null;
    });
    try {
      await context.read<AuthProvider>().authService.sendEmailVerification();
      if (!mounted) return;
      setState(() {
        _info = isEn ? 'Verification email sent' : 'Doğrulama e-postası gönderildi';
        _canResend = false;
        _cooldownSec = 30;
      });
      _cooldownTimer?.cancel();
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        setState(() {
          _cooldownSec--;
          if (_cooldownSec <= 0) {
            _canResend = true;
            t.cancel();
          }
        });
      });
    } on FirebaseAuthException catch (e) {
      setState(() => _error = isEn ? 'Send error: ${e.code}' : 'Gönderim hatası: ${e.code}');
    } catch (e) {
      setState(() => _error = isEn ? 'Failed to send' : 'Gönderim başarısız');
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().signOut();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEn = !AppLocalizations.of(context)!.isTurkish;
    final email = context.watch<AuthProvider>().firebaseUser?.email ?? '';

    return AuthScaffold(
      title: isEn ? 'Email verification' : 'Email doğrulama',
      subtitle: isEn ? 'Registration complete — one more step' : 'Kayıt tamamlandı, sadece bir adım kaldı',
      child: Column(
        children: [
          const Icon(Icons.mark_email_unread_outlined,
              size: 72, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            isEn
                ? 'We sent a verification link to $email. Please check your inbox and click the link.'
                : 'Sana $email adresine bir doğrulama linki gönderdik. Lütfen email kutunu kontrol et ve linke tıkla.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            isEn
                ? 'You will be forwarded automatically once verified.'
                : 'Doğrulama tamamlandığında otomatik olarak devam edilecek.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
          if (_info != null) ...[
            const SizedBox(height: 12),
            Text(
              _info!,
              style: const TextStyle(color: AppColors.success, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: AppColors.danger, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _checkVerified,
            icon: const Icon(Icons.refresh),
            label: Text(isEn ? 'I VERIFIED' : 'DOĞRULADIM'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _canResend ? _resend : null,
            icon: const Icon(Icons.send_outlined),
            label: Text(_canResend
                ? (isEn ? 'Resend email' : 'Maili tekrar gönder')
                : _cooldownSec > 0
                    ? (isEn ? 'Resend ($_cooldownSec s)' : 'Tekrar gönder ($_cooldownSec sn)')
                    : (isEn ? 'Resend email' : 'Maili tekrar gönder')),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: _logout,
            child: Text(isEn ? 'Sign out' : 'Çıkış yap'),
          ),
        ],
      ),
    );
  }
}
