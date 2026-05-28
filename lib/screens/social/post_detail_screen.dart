// =============================================
// screens/social/post_detail_screen.dart
// Full post view + nested comments (max 2 levels) + input to write
// a new comment or reply to an existing one.
// =============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_background.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/comment.dart';
import '../../models/post.dart';
import '../../models/post_report.dart';
import '../../providers/auth_provider.dart';
import '../../services/comment_service.dart';
import '../../services/post_service.dart';
import 'create_post_sheet.dart';
import 'widgets/comment_tile.dart';
import 'widgets/post_card.dart';
import 'widgets/report_sheet.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.postId});

  final String postId;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _postService = PostService();
  final _commentService = CommentService();
  final _commentCtrl = TextEditingController();
  String? _replyToCommentId;
  String? _replyToUsername;
  bool _sending = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      final auth = context.read<AuthProvider>();
      final user = auth.appUser;
      if (user == null) return;
      await _commentService.createComment(
        postId: widget.postId,
        authorId: user.uid,
        authorUsername: user.username,
        authorAvatarSeed: user.avatarSeed,
        content: text,
        parentCommentId: _replyToCommentId,
      );
      if (!mounted) return;
      setState(() {
        _commentCtrl.clear();
        _replyToCommentId = null;
        _replyToUsername = null;
      });
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (!mounted) return;
      final isEn = !AppLocalizations.of(context)!.isTurkish;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEn ? 'Could not send: $e' : 'Gönderilemedi: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _handleDeleteComment(Comment c) async {
    final l10n = AppLocalizations.of(context)!;
    final isEn = !l10n.isTurkish;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEn ? 'Delete Comment' : 'Yorumu Sil'),
        content: Text(isEn
            ? 'Are you sure you want to delete this comment?'
            : 'Bu yorumu silmek istediğine emin misin?'),
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
      await _commentService.deleteComment(
        postId: widget.postId,
        commentId: c.id,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEn ? 'Could not delete: $e' : 'Silinemedi: $e')));
    }
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
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEn ? 'Could not delete: $e' : 'Silinemedi: $e')));
    }
  }

  void _startReply(Comment c) {
    setState(() {
      _replyToCommentId = c.id;
      _replyToUsername = c.authorUsername;
    });
  }

  void _cancelReply() {
    setState(() {
      _replyToCommentId = null;
      _replyToUsername = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEn = !AppLocalizations.of(context)!.isTurkish;
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(isEn ? 'Post' : 'Paylaşım'),
        ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<Post?>(
              stream: _postService.postStream(widget.postId),
              builder: (context, postSnap) {
                if (postSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final post = postSnap.data;
                if (post == null) {
                  return Center(
                    child: Text(isEn
                        ? 'Post not found (may have been deleted)'
                        : 'Paylaşım bulunamadı (silinmiş olabilir)'),
                  );
                }
                return StreamBuilder<List<Comment>>(
                  stream: _commentService.streamComments(widget.postId),
                  builder: (context, commentsSnap) {
                    final comments = commentsSnap.data ?? const <Comment>[];
                    final topLevel = comments
                        .where((c) => c.parentCommentId == null)
                        .toList();
                    final childrenByParent = <String, List<Comment>>{};
                    for (final c in comments) {
                      if (c.parentCommentId != null) {
                        childrenByParent
                            .putIfAbsent(c.parentCommentId!, () => [])
                            .add(c);
                      }
                    }

                    return ListView(
                      padding: const EdgeInsets.only(bottom: 80),
                      children: [
                        PostCard(
                          post: post,
                          postService: _postService,
                          onTap: () {},
                          onEdit: () async {
                            await showCreatePostSheet(context,
                                editPost: post);
                          },
                          onDelete: () => _handleDeletePost(post),
                          onReport: () => showReportSheet(
                            context,
                            target: ReportTarget.post,
                            targetId: post.id,
                          ),
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 12, 16, 6),
                          child: Text(
                            isEn
                                ? 'Comments (${post.commentCount})'
                                : 'Yorumlar (${post.commentCount})',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (topLevel.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Text(
                                isEn
                                    ? 'No comments yet. Be the first!'
                                    : 'Henüz yorum yok. İlk sen yaz!',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6)),
                              ),
                            ),
                          ),
                        ...topLevel.expand((parent) {
                          final children =
                              childrenByParent[parent.id] ?? const [];
                          return [
                            CommentTile(
                              comment: parent,
                              onReply: () => _startReply(parent),
                              onDelete: () => _handleDeleteComment(parent),
                              onReport: () => showReportSheet(
                                context,
                                target: ReportTarget.comment,
                                targetId: '${widget.postId}/${parent.id}',
                              ),
                            ),
                            for (final child in children)
                              CommentTile(
                                comment: child,
                                indent: 36,
                                onReply: () => _startReply(parent),
                                onDelete: () =>
                                    _handleDeleteComment(child),
                                onReport: () => showReportSheet(
                                  context,
                                  target: ReportTarget.comment,
                                  targetId:
                                      '${widget.postId}/${child.id}',
                                ),
                              ),
                          ];
                        }),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          _buildComposer(context, isEn: isEn),
        ],
      ),
      ),
    );
  }

  Widget _buildComposer(BuildContext context, {bool isEn = false}) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.08),
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_replyToUsername != null)
              Row(
                children: [
                  Icon(Icons.reply,
                      size: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      isEn ? 'Reply: $_replyToUsername' : 'Yanıt: $_replyToUsername',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  IconButton(
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _cancelReply,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentCtrl,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: isEn ? 'Write a comment...' : 'Yorum yaz...',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sending ? null : _sendComment,
                  icon: _sending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send, color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
