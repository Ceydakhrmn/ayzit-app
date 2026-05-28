// =============================================
// screens/auth/forgot_password_screen.dart
// Send password reset email via Firebase Auth.
// =============================================

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import 'auth_scaffold.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final isEn = !AppLocalizations.of(context)!.isTurkish;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context
          .read<AuthProvider>()
          .authService
          .sendPasswordResetEmail(_emailCtrl.text);
      if (!mounted) return;
      setState(() => _sent = true);
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _mapError(e, isEn: isEn));
    } catch (e) {
      setState(() => _error = isEn ? 'Unexpected error' : 'Beklenmeyen hata');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapError(FirebaseAuthException e, {bool isEn = false}) {
    switch (e.code) {
      case 'invalid-email':
        return isEn ? 'Invalid email address' : 'Geçersiz email adresi';
      case 'user-not-found':
        return isEn ? 'No account found with this email' : 'Bu email ile kayıtlı hesap bulunamadı';
      default:
        return isEn ? 'Failed to send: ${e.code}' : 'Gönderim başarısız: ${e.code}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = !AppLocalizations.of(context)!.isTurkish;
    return AuthScaffold(
      showBack: true,
      title: isEn ? 'Forgot password' : 'Şifremi unuttum',
      subtitle: _sent
          ? (isEn ? 'Check your inbox' : 'Email kutunu kontrol et')
          : (isEn ? 'We\'ll send you a reset link' : 'Sana sıfırlama linki gönderelim'),
      child: _sent
          ? Column(
              children: [
                const Icon(Icons.mark_email_read_outlined,
                    size: 64, color: AppColors.primary),
                const SizedBox(height: 12),
                Text(
                  isEn
                      ? 'A reset link has been sent to ${_emailCtrl.text.trim()}.'
                      : '${_emailCtrl.text.trim()} adresine sıfırlama linki gönderildi.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(isEn ? 'BACK TO SIGN IN' : 'GİRİŞE DÖN'),
                ),
              ],
            )
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    enableSuggestions: false,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return isEn ? 'Email is required' : 'Email gerekli';
                      if (!s.contains('@')) return isEn ? 'Enter a valid email' : 'Geçerli bir email girin';
                      return null;
                    },
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(
                          color: AppColors.danger, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loading ? null : _send,
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(isEn ? 'SEND RESET LINK' : 'SIFIRLAMA LİNKİ GÖNDER'),
                  ),
                ],
              ),
            ),
    );
  }
}
