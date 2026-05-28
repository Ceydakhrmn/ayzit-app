// =============================================
// screens/social/create_post_sheet.dart
// Bottom sheet for creating a new post or editing an existing one.
// Runs the client-side profanity filter before writing to Firestore.
// =============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/profanity_filter.dart';
import '../../l10n/app_localizations.dart';
import '../../models/post.dart';
import '../../providers/auth_provider.dart';
import '../../services/post_service.dart';
import '../../services/profanity_service.dart';

Future<bool?> showCreatePostSheet(BuildContext context, {Post? editPost}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
      ),
      child: _CreatePostSheet(editPost: editPost),
    ),
  );
}

class _CreatePostSheet extends StatefulWidget {
  const _CreatePostSheet({this.editPost});

  final Post? editPost;

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  late final TextEditingController _ctrl;
  bool _anonymous = false;
  bool _loading = false;
  String? _error;

  final _postService = PostService();
  final _profanityService = ProfanityService();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.editPost?.content ?? '');
    _anonymous = widget.editPost?.isAnonymous ?? false;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _isEdit => widget.editPost != null;

  Future<void> _submit() async {
    final text = _ctrl.text.trim();
    // Capture context-dependent references before any await
    final isEn = !AppLocalizations.of(context)!.isTurkish;
    final auth = context.read<AuthProvider>();
    if (text.isEmpty) {
      setState(() => _error = isEn ? 'Post cannot be empty' : 'Boş post gönderemezsin');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Profanity check
      final badWords = await _profanityService.loadList();
      if (!mounted) return;
      if (ProfanityFilter.contains(text, badWords)) {
        setState(() => _error = isEn ? 'Content violates community guidelines' : 'İçerik topluluk kurallarına uygun değil');
        return;
      }
      final user = auth.appUser;
      if (user == null) {
        setState(() => _error = isEn ? 'Sign in required' : 'Giriş gerekli');
        return;
      }

      if (_isEdit) {
        await _postService.updatePostContent(
          postId: widget.editPost!.id,
          newContent: text,
        );
      } else {
        await _postService.createPost(
          authorId: user.uid,
          authorUsername: user.username,
          authorAvatarSeed: user.avatarSeed,
          content: text,
          isAnonymous: _anonymous,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = isEn ? 'Failed to send: $e' : 'Gönderim başarısız: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = !AppLocalizations.of(context)!.isTurkish;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                _isEdit
                    ? (isEn ? 'Edit Post' : 'Postu Düzenle')
                    : (isEn ? 'New Post' : 'Yeni Paylaşım'),
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              IconButton(
                onPressed:
                    _loading ? null : () => Navigator.of(context).pop(false),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _ctrl,
            maxLines: 8,
            minLines: 4,
            autofocus: true,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              hintText: isEn ? 'What\'s on your mind?' : 'Ne düşünüyorsun?',
              hintStyle: const TextStyle(color: Colors.black45),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          if (!_isEdit)
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _anonymous,
              onChanged: _loading ? null : (v) => setState(() => _anonymous = v),
              title: Text(isEn ? 'Post anonymously' : 'Anonim paylaş'),
              subtitle: Text(isEn ? 'Your username won\'t appear in the feed' : 'Kullanıcı adın feed\'de gözükmez'),
            ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: AppColors.danger, fontSize: 13),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(_isEdit ? (isEn ? 'SAVE' : 'KAYDET') : (isEn ? 'POST' : 'PAYLAŞ')),
          ),
        ],
      ),
    );
  }
}
