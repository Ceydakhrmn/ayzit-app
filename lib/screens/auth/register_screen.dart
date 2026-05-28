// =============================================
// screens/auth/register_screen.dart
// Email + password registration with username uniqueness + display name.
// After successful registration: creates Firebase Auth user, reserves
// username + creates Firestore profile atomically, sends verification
// email. AuthGate routes to VerifyEmailScreen automatically.
// =============================================

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_service.dart';
import 'auth_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _displayNameCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _usernameCtrl.dispose();
    _displayNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final isEn = !AppLocalizations.of(context)!.isTurkish;
    setState(() {
      _loading = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();

    try {
      // Cheap pre-check (the transaction below is the real claim).
      final available = await auth.userService
          .isUsernameAvailable(_usernameCtrl.text);
      if (!available) {
        setState(() => _error = isEn ? 'This username is taken' : 'Bu kullanıcı adı alınmış');
        return;
      }

      final cred = await auth.authService.signUpWithEmail(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );

      final uid = cred.user!.uid;

      // Force-refresh the ID token so Firestore rules see request.auth
      // immediately after account creation.
      await cred.user!.getIdToken(true);

      try {
        await auth.userService.createUserProfile(
          uid: uid,
          email: _emailCtrl.text.trim(),
          username: _usernameCtrl.text,
          displayName: _displayNameCtrl.text,
        );
      } on UsernameTaken {
        // Rollback the freshly-created auth user so the email can be reused.
        try {
          await cred.user?.delete();
        } catch (_) {}
        setState(() => _error = isEn ? 'This username is taken' : 'Bu kullanıcı adı alınmış');
        return;
      } on FirebaseException catch (e) {
        // Firestore (or other Firebase) failed AFTER the auth user was
        // created — roll back the auth user so the email can be reused.
        try {
          await cred.user?.delete();
        } catch (_) {}
        setState(() => _error = _mapFirestoreError(e, isEn: isEn));
        return;
      }

      await auth.authService.updateDisplayName(_displayNameCtrl.text.trim());
      await auth.authService.sendEmailVerification();
      // AuthGate routes to VerifyEmailScreen automatically.
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: code=${e.code} msg=${e.message} plugin=${e.plugin}');
      setState(() => _error = '[Auth:${e.code}] ${e.message ?? _mapError(e, isEn: isEn)}');
    } on FirebaseException catch (e) {
      debugPrint('FirebaseException: code=${e.code} msg=${e.message} plugin=${e.plugin}');
      setState(() => _error = '[FS:${e.code}] ${e.message ?? _mapFirestoreError(e, isEn: isEn)}');
    } catch (e, st) {
      debugPrint('Register error: $e\n$st');
      setState(() => _error = isEn ? 'Error: $e' : 'Hata: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapFirestoreError(FirebaseException e, {bool isEn = false}) {
    switch (e.code) {
      case 'unavailable':
        return isEn
            ? 'Cannot reach server. Check your internet connection and try again.'
            : 'Sunucuya ulaşılamıyor. İnternet bağlantınızı kontrol edip tekrar deneyin.';
      case 'permission-denied':
        return isEn ? 'Permission error. Please try again later.' : 'Yetki hatası. Lütfen daha sonra tekrar deneyin.';
      case 'deadline-exceeded':
        return isEn ? 'Request timed out. Try again.' : 'İstek zaman aşımına uğradı. Tekrar deneyin.';
      case 'unknown':
        return isEn
            ? 'Server connection error. Check your internet connection and try again.'
            : 'Sunucu bağlantı hatası. İnternet bağlantınızı kontrol edip tekrar deneyin.';
      default:
        return isEn ? 'Registration failed: ${e.code}' : 'Kayıt tamamlanamadı: ${e.code}';
    }
  }

  Future<void> _signUpGoogle() async {
    final isEn = !AppLocalizations.of(context)!.isTurkish;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().authService.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _mapError(e, isEn: isEn));
    } catch (e) {
      setState(() => _error = isEn ? 'Google sign-up failed' : 'Google kaydı başarısız');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapError(FirebaseAuthException e, {bool isEn = false}) {
    switch (e.code) {
      case 'email-already-in-use':
        return isEn ? 'This email is already registered' : 'Bu email zaten kayıtlı';
      case 'invalid-email':
        return isEn ? 'Invalid email address' : 'Geçersiz email adresi';
      case 'weak-password':
        return isEn ? 'Password is too weak (min 6 characters)' : 'Şifre çok zayıf (en az 6 karakter)';
      case 'operation-not-allowed':
        return isEn ? 'Email/password sign-in is not enabled' : 'Email/şifre girişi etkin değil';
      default:
        return isEn ? 'Registration failed: ${e.code}' : 'Kayıt başarısız: ${e.code}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = !AppLocalizations.of(context)!.isTurkish;
    return AuthScaffold(
      showBack: true,
      title: isEn ? 'Create account' : 'Hesap oluştur',
      subtitle: isEn ? 'Sign up to join the community' : 'Topluluğa katılmak için kayıt ol',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _displayNameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: isEn ? 'Display name' : 'İsim (görünen ad)',
                prefixIcon: const Icon(Icons.badge_outlined),
              ),
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.length < 2) return isEn ? 'At least 2 characters' : 'En az 2 karakter';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _usernameCtrl,
              decoration: InputDecoration(
                labelText: isEn ? 'Username' : 'Kullanıcı adı',
                prefixIcon: const Icon(Icons.alternate_email),
                helperText: isEn ? '3-20 chars, lowercase/digits/._' : '3-20 karakter, küçük harf/rakam/._',
              ),
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return isEn ? 'Username is required' : 'Kullanıcı adı gerekli';
                if (!UserService.isValidUsername(s)) {
                  return isEn ? 'Invalid username' : 'Geçersiz kullanıcı adı';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
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
                if (!s.contains('@') || !s.contains('.')) {
                  return isEn ? 'Enter a valid email' : 'Geçerli bir email girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: isEn ? 'Password' : 'Şifre',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (v) {
                final s = v ?? '';
                if (s.length < 6) return isEn ? 'At least 6 characters' : 'En az 6 karakter';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: isEn ? 'Confirm password' : 'Şifre (tekrar)',
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              validator: (v) {
                if (v != _passwordCtrl.text) return isEn ? 'Passwords do not match' : 'Şifreler eşleşmiyor';
                return null;
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.danger, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _register,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(isEn ? 'SIGN UP' : 'KAYIT OL'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    isEn ? 'or' : 'veya',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loading ? null : _signUpGoogle,
              icon: const Icon(Icons.g_mobiledata, size: 28),
              label: Text(isEn ? 'Continue with Google' : 'Google ile devam et'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(isEn ? 'Already have an account? ' : 'Zaten hesabın var mı? '),
                TextButton(
                  onPressed:
                      _loading ? null : () => Navigator.of(context).pop(),
                  child: Text(isEn ? 'Sign in' : 'Giriş yap'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
