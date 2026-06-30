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
import '../../l10n/app_localizations.dart';
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
    final isEn = !AppLocalizations.of(context)!.isTurkish;
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
          setState(() => _error = isEn ? 'New password must be at least 6 characters' : 'Yeni şifre en az 6 karakter');
          return;
        }
        if (_currentPwCtrl.text.isEmpty) {
          setState(() => _error = isEn ? 'Enter your current password' : 'Mevcut şifreyi girmelisin');
          return;
        }
        await auth.authService
            .reauthenticateWithPassword(_currentPwCtrl.text);
        await auth.authService.updatePassword(newPw);
        _currentPwCtrl.clear();
        _newPwCtrl.clear();
      }

      if (!mounted) return;
      setState(() => _info = isEn ? 'Changes saved' : 'Değişiklikler kaydedildi');
    } on UsernameTaken {
      setState(() => _error = !AppLocalizations.of(context)!.isTurkish
          ? 'This username is taken'
          : 'Bu kullanıcı adı alınmış');
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _mapError(e, isEn: !AppLocalizations.of(context)!.isTurkish));
    } catch (e) {
      setState(() => _error = !AppLocalizations.of(context)!.isTurkish ? 'Could not save: $e' : 'Kaydedilemedi: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapError(FirebaseAuthException e, {bool isEn = false}) {
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return isEn ? 'Current password is incorrect' : 'Mevcut şifre hatalı';
      case 'weak-password':
        return isEn ? 'New password is too weak' : 'Yeni şifre çok zayıf';
      case 'requires-recent-login':
        return isEn ? 'Please sign in again and try again' : 'Lütfen tekrar giriş yap ve yeniden dene';
      default:
        return isEn ? 'Error: ${e.code}' : 'Hata: ${e.code}';
    }
  }

  Future<void> _deleteAccount() async {
    // Capture before any await
    final auth = context.read<AuthProvider>();
    final isEn = !AppLocalizations.of(context)!.isTurkish;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEn ? 'Delete Account' : 'Hesabı Sil'),
        content: Text(
          isEn
              ? 'This action cannot be undone. All your data, posts, and comments will be deleted. Are you sure?'
              : 'Bu işlem geri alınamaz. Tüm verilerin, paylaşımların ve yorumların silinecek. Emin misin?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(isEn ? 'Cancel' : 'Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isEn ? 'Delete Account' : 'Hesabı Sil',
                style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;

    final pw = await _askPassword(isEn: isEn);
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
      setState(() => _error = _mapError(e, isEn: isEn));
    } catch (e) {
      setState(() => _error = isEn ? 'Deletion failed: $e' : 'Silme başarısız: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<String?> _askPassword({bool isEn = false}) async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEn ? 'Verify Identity' : 'Kimliğini Doğrula'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEn
                  ? 'Enter your password to continue. Leave blank if you signed in with Google.'
                  : 'Devam etmek için şifreni gir. Google ile giriş yaptıysan boş bırak.',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: isEn ? 'Password' : 'Şifre',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: Text(isEn ? 'Cancel' : 'Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text),
            child: Text(isEn ? 'Continue' : 'Devam'),
          ),
        ],
      ),
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final isEn = !AppLocalizations.of(context)!.isTurkish;
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(isEn ? 'Edit Profile' : 'Profili Düzenle'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: Text(isEn ? 'SAVE' : 'KAYDET'),
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
                decoration: InputDecoration(
                  labelText: isEn ? 'Display Name' : 'Görünen Ad',
                  prefixIcon: const Icon(Icons.badge_outlined),
                ),
                validator: (v) {
                  if ((v ?? '').trim().length < 2) return isEn ? 'At least 2 characters' : 'En az 2 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _usernameCtrl,
                decoration: InputDecoration(
                  labelText: isEn ? 'Username' : 'Kullanıcı adı',
                  prefixIcon: const Icon(Icons.alternate_email),
                  helperText: isEn ? '3-20 chars, lowercase/digits/._' : '3-20 karakter, küçük harf/rakam/._',
                ),
                validator: (v) {
                  if (!UserService.isValidUsername(v ?? '')) {
                    return isEn ? 'Invalid username' : 'Geçersiz kullanıcı adı';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              Text(
                isEn ? 'Change password (optional)' : 'Şifreyi değiştir (opsiyonel)',
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
                decoration: InputDecoration(
                  labelText: isEn ? 'Current password' : 'Mevcut şifre',
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _newPwCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: isEn ? 'New password' : 'Yeni şifre',
                  prefixIcon: const Icon(Icons.lock_reset),
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
                label: Text(isEn ? 'DELETE ACCOUNT' : 'HESABI SİL'),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
