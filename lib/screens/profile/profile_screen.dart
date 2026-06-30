// =============================================
// screens/profile/profile_screen.dart
// Full profile tab:
//   • circular avatar + username + email
//   • stats (postCount, likesReceived)
//   • rows: edit profile, settings, logout
//   • "my posts" list below
// =============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_background.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/post.dart';
import '../../models/post_report.dart';
import '../../providers/auth_provider.dart';
import '../../services/post_service.dart';
import '../settings_screen.dart';
import '../social/create_post_sheet.dart';
import '../social/post_detail_screen.dart';
import '../social/widgets/post_card.dart';
import '../social/widgets/report_sheet.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  final _postService = PostService();
  final List<Post> _myPosts = [];
  bool _loading = true;
  String? _lastUidLoaded;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = context.watch<AuthProvider>().firebaseUser?.uid;
    if (uid != null && uid != _lastUidLoaded) {
      _lastUidLoaded = uid;
      _loadMyPosts(uid);
    }
  }

  Future<void> _loadMyPosts(String uid) async {
    setState(() => _loading = true);
    try {
      final result = await _postService.fetchByAuthor(uid);
      if (!mounted) return;
      setState(() {
        _myPosts
          ..clear()
          ..addAll(result.posts);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    final uid = context.read<AuthProvider>().firebaseUser?.uid;
    if (uid != null) await _loadMyPosts(uid);
  }

  Future<void> _handleDeletePost(Post post) async {
    final l10n = AppLocalizations.of(context)!;
    final isEn = !l10n.isTurkish;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEn ? 'Delete Post' : 'Postu Sil'),
        content: Text(isEn
            ? 'Are you sure you want to delete this post?'
            : 'Bu paylaşımı silmek istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.dismissBtn),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.deleteBtn,
                style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _postService.deletePost(post.id);
      if (!mounted) return;
      setState(() => _myPosts.removeWhere((p) => p.id == post.id));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEn ? 'Could not delete: $e' : 'Silinemedi: $e')));
    }
  }

  Future<void> _confirmLogout() async {
    final l10n = AppLocalizations.of(context)!;
    final isEn = !l10n.isTurkish;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEn ? 'Log Out' : 'Çıkış Yap'),
        content: Text(isEn
            ? 'Are you sure you want to sign out?'
            : 'Oturumu kapatmak istediğinden emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.dismissBtn),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.logoutBtn,
                style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    await context.read<AuthProvider>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final auth = context.watch<AuthProvider>();
    final user = auth.appUser;
    final l10n = AppLocalizations.of(context)!;
    final isEn = !l10n.isTurkish;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(l10n.profileLabel),
        ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            const SizedBox(height: 20),
            // Avatar
            Center(child: _ProfileAvatar(user: user, size: 96)),
            const SizedBox(height: 12),
            // Username
            Center(
              child: Text(
                user?.username.isNotEmpty == true ? user!.username : '—',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                user?.email ?? auth.firebaseUser?.email ?? '',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      label: l10n.isTurkish ? 'Paylaşım' : 'Posts',
                      value: '${user?.postCount ?? 0}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      label: l10n.isTurkish ? 'Beğeni' : 'Likes',
                      value: '${user?.likesReceived ?? 0}',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            ListTile(
              leading:
                  const Icon(Icons.edit_outlined, color: AppColors.primary),
              title: Text(l10n.editProfileLabel),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EditProfileScreen(),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined,
                  color: AppColors.primary),
              title: Text(l10n.settingsLabel),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.danger),
              title: Text(l10n.logoutBtn,
                  style: const TextStyle(color: AppColors.danger)),
              onTap: _confirmLogout,
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                l10n.myPostsLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_myPosts.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    isEn ? 'No posts yet' : 'Henüz paylaşımın yok',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ),
              )
            else
              ..._myPosts.map(
                (post) => PostCard(
                  post: post,
                  postService: _postService,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PostDetailScreen(postId: post.id),
                    ),
                  ),
                  onEdit: () async {
                    final updated =
                        await showCreatePostSheet(context, editPost: post);
                    if (updated == true) _refresh();
                  },
                  onDelete: () => _handleDeletePost(post),
                  onReport: () => showReportSheet(
                    context,
                    target: ReportTarget.post,
                    targetId: post.id,
                  ),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.user, required this.size});

  final dynamic user; // AppUser?
  final double size;

  @override
  Widget build(BuildContext context) {
    final seed = user?.avatarSeed ??
        user?.username ??
        user?.email ??
        '?';
    final label = user?.username ?? user?.email ?? '?';

    final color = _colorFromSeed(seed.toString());
    final initial = label.toString().isEmpty
        ? '?'
        : label.toString().substring(0, 1).toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Color _colorFromSeed(String seed) {
    const palette = [
      Color(0xFF7C3AED),
      Color(0xFFEC4899),
      Color(0xFFEF4444),
      Color(0xFFF97316),
      Color(0xFFEAB308),
      Color(0xFF22C55E),
      Color(0xFF14B8A6),
      Color(0xFF3B82F6),
      Color(0xFF6366F1),
      Color(0xFF8B5CF6),
      Color(0xFFA855F7),
      Color(0xFFD946EF),
    ];
    if (seed.isEmpty) return palette.first;
    final hash =
        seed.codeUnits.fold<int>(0, (acc, c) => (acc * 31 + c) & 0x7fffffff);
    return palette[hash % palette.length];
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style:
                const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
