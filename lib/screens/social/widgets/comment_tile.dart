// =============================================
// screens/social/widgets/comment_tile.dart
// Single comment row. Includes author header, content, reply button,
// and a more-menu (delete for own, report for others').
// =============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/relative_time.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/comment.dart';
import '../../../providers/auth_provider.dart';
import 'avatar_circle.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({
    super.key,
    required this.comment,
    required this.onReply,
    required this.onDelete,
    required this.onReport,
    this.indent = 0,
  });

  final Comment comment;
  final VoidCallback onReply;
  final VoidCallback onDelete;
  final VoidCallback onReport;
  final double indent;

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().firebaseUser?.uid;
    final isMine = uid != null && uid == comment.authorId;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.fromLTRB(16 + indent, 10, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AvatarCircle(
            seed: comment.authorAvatarSeed,
            label: comment.authorUsername,
            size: 34,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.authorUsername.isEmpty
                            ? '—'
                            : comment.authorUsername,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      RelativeTime.format(comment.createdAt, locale: l10n.localeName),
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 4),
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      iconSize: 18,
                      icon: const Icon(Icons.more_horiz),
                      onSelected: (v) {
                        if (v == 'delete') onDelete();
                        if (v == 'report') onReport();
                      },
                      itemBuilder: (ctx) {
                        final l10n = AppLocalizations.of(ctx)!;
                        return [
                          if (isMine)
                            PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                dense: true,
                                leading: const Icon(Icons.delete_outline,
                                    color: AppColors.danger),
                                title: Text(l10n.deleteBtn,
                                    style: const TextStyle(color: AppColors.danger)),
                              ),
                            )
                          else
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
                const SizedBox(height: 2),
                Text(
                  comment.content,
                  style: const TextStyle(fontSize: 14, height: 1.3),
                ),
                const SizedBox(height: 4),
                // Only top-level comments show a reply button (max 2 levels
                // enforced in CommentService as well).
                if (comment.parentCommentId == null)
                  InkWell(
                    onTap: onReply,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        l10n.isTurkish ? 'Yanıtla' : 'Reply',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
