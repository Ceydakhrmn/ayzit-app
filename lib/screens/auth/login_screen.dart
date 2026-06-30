// =============================================
// screens/auth/login_screen.dart
// Email + Password sign-in + Google Sign-In.
// After successful sign-in, AuthGate automatically routes forward.
// =============================================

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import 'auth_scaffold.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signInEmail() async {
    if (!_formKey.currentState!.validate()) return;
    final isEn = !AppLocalizations.of(context)!.isTurkish;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = context.read<AuthProvider>().authService;
      await auth.signInWithEmail(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
      // AuthGate will route automatically
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _mapError(e, isEn: isEn));
    } catch (e) {
      setState(() => _error = isEn ? 'An unexpected error occurred' : 'Beklenmeyen bir hata oluştu');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInGoogle() async {
    final isEn = !AppLocalizations.of(context)!.isTurkish;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = context.read<AuthProvider>().authService;
      await auth.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _mapError(e, isEn: isEn));
    } catch (e) {
      setState(() => _error = isEn ? 'Google sign-in failed' : 'Google girişi başarısız');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapError(FirebaseAuthException e, {bool isEn = false}) {
    switch (e.code) {
      case 'invalid-email':
        return isEn ? 'Invalid email address' : 'Geçersiz email adresi';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return isEn ? 'Incorrect email or password' : 'Email veya şifre hatalı';
      case 'user-disabled':
        return isEn ? 'This account has been disabled' : 'Bu hesap devre dışı bırakılmış';
      case 'too-many-requests':
        return isEn ? 'Too many attempts. Please try again later' : 'Çok fazla deneme. Lütfen daha sonra tekrar deneyin';
      default:
        return isEn ? 'Sign-in failed: ${e.code}' : 'Giriş başarısız: ${e.code}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = !AppLocalizations.of(context)!.isTurkish;
    return AuthScaffold(
      title: isEn ? 'Welcome' : 'Hoş geldin',
      subtitle: isEn ? 'Sign in to continue' : 'Devam etmek için giriş yap',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.visiblePassword,
              autocorrect: false,
              enableSuggestions: false,
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
              autofillHints: const [AutofillHints.password],
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
                if ((v ?? '').isEmpty) return isEn ? 'Password is required' : 'Şifre gerekli';
                return null;
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _loading
                    ? null
                    : () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        ),
                child: Text(isEn ? 'Forgot password' : 'Şifremi unuttum'),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.danger, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _signInEmail,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(isEn ? 'SIGN IN' : 'GİRİŞ YAP'),
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
              onPressed: _loading ? null : _signInGoogle,
              icon: const Icon(Icons.g_mobiledata, size: 28),
              label: Text(isEn ? 'Continue with Google' : 'Google ile devam et'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(isEn ? 'No account? ' : 'Hesabın yok mu? '),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          ),
                  child: Text(isEn ? 'Sign up' : 'Kayıt ol'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
