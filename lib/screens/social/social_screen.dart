// =============================================
// screens/social/social_screen.dart
// Social tab with two sub-tabs:
//   • Latest  — createdAt DESC
//   • Popular — current month, likeCount DESC
// Features: infinite scroll, pull-to-refresh, FAB → create post sheet,
// per-card actions (edit/delete/report), navigation to PostDetailScreen.
// =============================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/post.dart';
import '../../models/post_report.dart';
import '../../services/post_service.dart';
import 'create_post_sheet.dart';
import 'post_detail_screen.dart';
import 'widgets/avatar_circle.dart';
import 'widgets/post_card.dart';
import 'widgets/report_sheet.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      Text(
                        !AppLocalizations.of(context)!.isTurkish ? 'Social' : 'Sosyal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                TabBar(
                  tabs: [
                    Tab(text: !AppLocalizations.of(context)!.isTurkish ? 'Latest' : 'En Yeni'),
                    Tab(text: !AppLocalizations.of(context)!.isTurkish ? 'Popular' : 'Popüler'),
                  ],
                ),
                const Expanded(
                  child: TabBarView(
                    children: [
                      _FeedList(mode: _FeedMode.latest),
                      _FeedList(mode: _FeedMode.popularThisMonth),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: AppColors.primary,
                onPressed: () async {
                  await showCreatePostSheet(context);
                },
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _FeedMode { latest, popularThisMonth }

class _FeedList extends StatefulWidget {
  const _FeedList({required this.mode});

  final _FeedMode mode;

  @override
  State<_FeedList> createState() => _FeedListState();
}

class _FeedListState extends State<_FeedList>
    with AutomaticKeepAliveClientMixin {
  final _service = PostService();
  final _scrollCtrl = ScrollController();

  final List<Post> _posts = [];
  DocumentSnapshot<Map<String, dynamic>>? _lastDoc;
  bool _initialLoading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;
  bool _firstLoadStarted = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    // initState içinde context'e bağlı widget'lar kullanılamaz;
    // ilk yükleme didChangeDependencies'e taşındı.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_firstLoadStarted) {
      _firstLoadStarted = true;
      _loadFirstPage();
    }
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >
            _scrollCtrl.position.maxScrollExtent - 300 &&
        !_loadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<PagedPosts> _fetch({DocumentSnapshot<Map<String, dynamic>>? after}) {
    switch (widget.mode) {
      case _FeedMode.latest:
        return _service.fetchLatest(startAfter: after);
      case _FeedMode.popularThisMonth:
        return _service.fetchPopularThisMonth(startAfter: after);
    }
  }

  Future<void> _loadFirstPage() async {
    final isEn = !AppLocalizations.of(context)!.isTurkish;
    setState(() {
      _initialLoading = true;
      _error = null;
    });
    try {
      final result = await _fetch();
      if (!mounted) return;
      setState(() {
        _posts
          ..clear()
          ..addAll(result.posts);
        _lastDoc = result.lastDoc;
        _hasMore = result.hasMore;
        _initialLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = isEn ? 'Could not load: $e' : 'Yüklenemedi: $e';
        _initialLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    final isEn = !AppLocalizations.of(context)!.isTurkish;
    try {
      final result = await _fetch();
      if (!mounted) return;
      setState(() {
        _posts
          ..clear()
          ..addAll(result.posts);
        _lastDoc = result.lastDoc;
        _hasMore = result.hasMore;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = isEn ? 'Refresh failed: $e' : 'Yenileme başarısız: $e');
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore || _lastDoc == null) return;
    setState(() => _loadingMore = true);
    try {
      final result = await _fetch(after: _lastDoc);
      if (!mounted) return;
      setState(() {
        _posts.addAll(result.posts);
        _lastDoc = result.lastDoc ?? _lastDoc;
        _hasMore = result.hasMore;
      });
    } catch (_) {
      // swallow — user can try again by scrolling
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _handleDelete(Post post) async {
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
            child: Text(
              l10n.deleteBtn,
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _service.deletePost(post.id);
      if (!mounted) return;
      setState(() => _posts.removeWhere((p) => p.id == post.id));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEn ? 'Could not delete: $e' : 'Silinemedi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_initialLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadFirstPage,
                child: Text(!AppLocalizations.of(context)!.isTurkish ? 'Retry' : 'Tekrar dene'),
              ),
            ],
          ),
        ),
      );
    }
    if (_posts.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Center(child: Text(!AppLocalizations.of(context)!.isTurkish ? 'No posts yet' : 'Henüz paylaşım yok')),
            ),
          ],
        ),
      );
    }

    final isPopular = widget.mode == _FeedMode.popularThisMonth;
    // Popular modda boş olmayan feed'in başına banner gelir
    final hasBanner = isPopular && _posts.isNotEmpty;
    final bannerOffset = hasBanner ? 1 : 0;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 80, top: 4),
        itemCount: _posts.length + bannerOffset + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Ayın popüleri banner'ı
          if (hasBanner && index == 0) {
            return _MonthTopBanner(
              post: _posts.first,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PostDetailScreen(postId: _posts.first.id),
                ),
              ),
            );
          }
          // Sonsuz scroll yükleme göstergesi
          final postIndex = index - bannerOffset;
          if (postIndex == _posts.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final post = _posts[postIndex];
          return PostCard(
            post: post,
            postService: _service,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PostDetailScreen(postId: post.id),
              ),
            ),
            onEdit: () async {
              final updated = await showCreatePostSheet(
                context,
                editPost: post,
              );
              if (updated == true) _refresh();
            },
            onDelete: () => _handleDelete(post),
            onReport: () => showReportSheet(
              context,
              target: ReportTarget.post,
              targetId: post.id,
            ),
          );
        },
      ),
    );
  }
}

// ── Ayın Popüleri Banner ────────────────────────────────────────────────────
class _MonthTopBanner extends StatelessWidget {
  const _MonthTopBanner({required this.post, required this.onTap});

  final Post post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isEn = !AppLocalizations.of(context)!.isTurkish;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final displayName = post.isAnonymous
        ? (isEn ? 'Anonymous' : 'Anonim')
        : (post.authorUsername.isEmpty ? '—' : post.authorUsername);

    final preview = post.content.length > 130
        ? '${post.content.substring(0, 130)}…'
        : post.content;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF3B1E6E), const Color(0xFF4A1252)]
                : [const Color(0xFF7C3AED), const Color(0xFFA855F7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık satırı
            Row(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  isEn ? 'POST OF THE MONTH' : 'AYININ POPÜLERİ',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                const Spacer(),
                // Beğeni sayısı rozeti
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite, size: 13, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likeCount}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Yazar satırı
            Row(
              children: [
                AvatarCircle(
                  seed: post.authorAvatarSeed,
                  label: displayName,
                  anonymous: post.isAnonymous,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // İçerik önizlemesi
            Text(
              preview,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            // Alt satır
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  isEn ? 'See full post' : 'Gönderiyi gör',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 11,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
