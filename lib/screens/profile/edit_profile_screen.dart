// =============================================
// screens/profile/edit_profile_screen.dart
// Edit username, display name, password. Danger zone: delete account.
// Password change requires re-authentication. Delete account requires
// re-authentication too (email/password OR Google).
// =============================================

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_background.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _displayNameCtrl;
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _info;
  String _originalUsername = '';

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().appUser;
    _originalUsername = user?.username ?? '';
    _usernameCtrl = TextEditingController(text: _originalUsername);
    _displayNameCtrl = TextEditingController(text: user?.displayName ?? '');
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _displayNameCtrl.dispose();
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
      _info = null;
    });
    try {
      final auth = context.read<AuthProvider>();
      final user = auth.appUser;
      if (user == null) return;

      final newUsername =
          UserService.normalizeUsername(_usernameCtrl.text);
      final newDisplayName = _displayNameCtrl.text.trim();

      if (newUsername != _originalUsername) {
        await auth.userService.changeUsername(
          uid: user.uid,
          oldUsername: _originalUsername,
          newUsername: newUsername,
        );
        _originalUsername = newUsername;
      }
      if (newDisplayName != user.displayName) {
        await auth.userService.updateDisplayName(user.uid, newDisplayName);
        await auth.authService.updateDisplayName(newDisplayName);
      }

      // Optional password change
      final newPw = _newPwCtrl.text;
      if (newPw.isNotEmpty) {
        if (newPw.length < 6) {
          setState(() => _error = 'Yeni şifre en az 6 karakter');
          return;
        }
        if (_currentPwCtrl.text.isEmpty) {
          setState(() => _error = 'Mevcut şifreyi girmelisin');
          return;
        }
        await auth.authService
            .reauthenticateWithPassword(_currentPwCtrl.text);
        await auth.authService.updatePassword(newPw);
        _currentPwCtrl.clear();
        _newPwCtrl.clear();
      }

      if (!mounted) return;
      setState(() => _info = 'Değişiklikler kaydedildi');
    } on UsernameTaken {
      setState(() => _error = 'Bu kullanıcı adı alınmış');
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _mapError(e));
    } catch (e) {
      setState(() => _error = 'Kaydedilemedi: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Mevcut şifre hatalı';
      case 'weak-password':
        return 'Yeni şifre çok zayıf';
      case 'requires-recent-login':
        return 'Lütfen tekrar giriş yap ve yeniden dene';
      default:
        return 'Hata: ${e.code}';
    }
  }

  Future<void> _deleteAccount() async {
    // Capture before any await
    final auth = context.read<AuthProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text(
          'Bu işlem geri alınamaz. Tüm verilerin, paylaşımların ve yorumların silinecek. Emin misin?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hesabı Sil',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;

    final pw = await _askPassword();
    if (pw == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = auth.appUser;
      if (user == null) return;

      if (pw.isNotEmpty) {
        await auth.authService.reauthenticateWithPassword(pw);
      } else {
        // Empty = Google-signed-in user path
        await auth.authService.reauthenticateWithGoogle();
      }
      await auth.userService.deleteUserProfile(user.uid, user.username);
      await auth.authService.deleteAuthAccount();
      // AuthProvider will tear everything down; AuthGate returns to Login.
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _mapError(e));
    } catch (e) {
      setState(() => _error = 'Silme başarısız: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<String?> _askPassword() async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kimliğini Doğrula'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Devam etmek için şifreni gir. Google ile giriş yaptıysan boş bırak.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Şifre',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text),
            child: const Text('Devam'),
          ),
        ],
      ),
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Profili Düzenle'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: const Text('KAYDET'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _displayNameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Görünen Ad',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (v) {
                  if ((v ?? '').trim().length < 2) return 'En az 2 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Kullanıcı adı',
                  prefixIcon: Icon(Icons.alternate_email),
                  helperText: '3-20 karakter, küçük harf/rakam/._',
                ),
                validator: (v) {
                  if (!UserService.isValidUsername(v ?? '')) {
                    return 'Geçersiz kullanıcı adı';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              Text(
                'Şifreyi değiştir (opsiyonel)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _currentPwCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mevcut şifre',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _newPwCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Yeni şifre',
                  prefixIcon: Icon(Icons.lock_reset),
                ),
              ),
              if (_info != null) ...[
                const SizedBox(height: 12),
                Text(_info!,
                    style: const TextStyle(
                        color: AppColors.success, fontSize: 13)),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style: const TextStyle(
                        color: AppColors.danger, fontSize: 13)),
              ],
              const SizedBox(height: 40),
              OutlinedButton.icon(
                onPressed: _loading ? null : _deleteAccount,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                ),
                icon: const Icon(Icons.delete_outline),
                label: const Text('HESABI SİL'),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
