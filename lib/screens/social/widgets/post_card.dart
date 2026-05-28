// =============================================
// screens/social/widgets/post_card.dart
// Card that renders a single post in the feed.
// Shows avatar, username (or "Anonim"), relative time, content,
// like/comment counters, and a more menu (edit/delete for own post,
// report for others').
// =============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/relative_time.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/post.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/post_service.dart';
import 'avatar_circle.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onReport,
    this.postService,
  });

  final Post post;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onReport;
  final PostService? postService;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final uid = auth.firebaseUser?.uid;
    final isMine = uid != null && uid == post.authorId;
    final effectiveService = postService ?? PostService();
    final l10n = AppLocalizations.of(context)!;
    final locale = l10n.localeName;

    final displayName = post.isAnonymous
        ? (l10n.isTurkish ? 'Anonim' : 'Anonymous')
        : (post.authorUsername.isEmpty ? '—' : post.authorUsername);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: avatar + name + time + more
              Row(
                children: [
                  AvatarCircle(
                    seed: post.authorAvatarSeed,
                    label: displayName,
                    anonymous: post.isAnonymous,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${RelativeTime.format(post.createdAt, locale: locale)}${post.edited ? (l10n.isTurkish ? ' • düzenlendi' : ' • edited') : ''}',
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
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                        case 'report':
                          onReport();
                          break;
                      }
                    },
                    itemBuilder: (ctx) {
                      final l10n = AppLocalizations.of(ctx)!;
                      return [
                        if (isMine) ...[
                          PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              dense: true,
                              leading: const Icon(Icons.edit_outlined),
                              title: Text(l10n.editBtn),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              dense: true,
                              leading: const Icon(Icons.delete_outline,
                                  color: AppColors.danger),
                              title: Text(l10n.deleteBtn,
                                  style: const TextStyle(color: AppColors.danger)),
                            ),
                          ),
                        ] else
                          PopupMenuItem(
                            value: 'report',
                            child: ListTile(
                              dense: true,
                              leading: const Icon(Icons.flag_outlined),
                              title: Text(l10n.reportBtn),
                            ),
                          ),
                      ];
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Content
              Text(
                post.content,
                style: const TextStyle(fontSize: 15, height: 1.35),
              ),
              const SizedBox(height: 12),
              // Actions row
              Row(
                children: [
                  _LikeButton(
                    post: post,
                    uid: uid,
                    postService: effectiveService,
                  ),
                  const SizedBox(width: 18),
                  Icon(Icons.mode_comment_outlined,
                      size: 20,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7)),
                  const SizedBox(width: 6),
                  Text(
                    '${post.commentCount}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LikeButton extends StatelessWidget {
  const _LikeButton({
    required this.post,
    required this.uid,
    required this.postService,
  });

  final Post post;
  final String? uid;
  final PostService postService;

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return Row(
        children: [
          const Icon(Icons.favorite_border, size: 20),
          const SizedBox(width: 6),
          Text('${post.likeCount}',
              style: const TextStyle(fontSize: 13)),
        ],
      );
    }
    return StreamBuilder<bool>(
      stream: postService.likeStream(postId: post.id, uid: uid!),
      builder: (context, snapshot) {
        final liked = snapshot.data ?? false;
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            try {
              await postService.toggleLike(postId: post.id, uid: uid!);
            } catch (_) {}
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: liked
                      ? AppColors.likeRed
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
                Text(
                  '${post.likeCount}',
                  style: TextStyle(
                    fontSize: 13,
                    color: liked
                        ? AppColors.likeRed
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
