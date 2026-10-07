// =============================================
// screens/social/activity_screen.dart
// Zil listesi: paylaşımlarına gelen yorumlar ve beğeniler.
// Açılınca listedeki kayıtlar okundu işaretlenir; bir kayda dokununca
// ilgili paylaşım açılır.
// =============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/relative_time.dart';
import '../../l10n/app_localizations.dart';
import '../../models/activity_item.dart';
import '../../providers/auth_provider.dart';
import '../../services/activity_service.dart';
import 'post_detail_screen.dart';
import 'widgets/avatar_circle.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final _service = ActivityService();
  bool _markedRead = false;
  String? _uid;
  Stream<List<ActivityItem>>? _stream;

  void _markReadOnce(String uid, List<ActivityItem> items) {
    if (_markedRead || items.isEmpty) return;
    _markedRead = true;
    // Ekranda gösterilenler okundu sayılır; kırmızı nokta kalkar.
    _service.markAllRead(uid, items).catchError((Object e) {
      debugPrint('ActivityScreen.markAllRead: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTr = AppLocalizations.of(context)!.isTurkish;
    final uid = context.watch<AuthProvider>().firebaseUser?.uid;
    final cs = Theme.of(context).colorScheme;
    if (uid != null && uid != _uid) {
      _uid = uid;
      _stream = _service.stream(uid);
    }

    return Scaffold(
      appBar: AppBar(title: Text(isTr ? 'Bildirimler' : 'Notifications')),
      body: uid == null
          ? const SizedBox.shrink()
          : StreamBuilder<List<ActivityItem>>(
              stream: _stream,
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(
                    child: Text(isTr
                        ? 'Bildirimler yüklenemedi.'
                        : 'Could not load notifications.'),
                  );
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snap.data!;
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _markReadOnce(uid, items));
                if (items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        isTr
                            ? 'Henüz bildirimin yok.\nPaylaşımlarına gelen yorum ve beğeniler burada görünür.'
                            : 'No notifications yet.\nComments and likes on your posts will show up here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.55)),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) =>
                      _ActivityTile(item: items[i], isTr: isTr),
                );
              },
            ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item, required this.isTr});

  final ActivityItem item;
  final bool isTr;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isComment = item.type == ActivityType.comment;
    final action = isComment
        ? (isTr ? ' paylaşımına yorum yaptı' : ' commented on your post')
        : (isTr ? ' paylaşımını beğendi' : ' liked your post');

    return ListTile(
      // Okunmamış kayıtlar hafif vurgulu.
      tileColor: item.read ? null : AppColors.primary.withValues(alpha: 0.06),
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          AvatarCircle(seed: item.actorUsername, label: item.actorUsername),
          Positioned(
            right: -4,
            bottom: -4,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: cs.surface,
              child: Icon(
                isComment ? Icons.chat_bubble : Icons.favorite,
                size: 13,
                color: isComment ? AppColors.primary : Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
      title: Text.rich(
        TextSpan(children: [
          TextSpan(
            text: item.actorUsername,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: action),
        ]),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isComment && (item.text ?? '').isNotEmpty)
            Text(
              '“${item.text}”',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          Text(
            RelativeTime.format(item.createdAt, locale: isTr ? 'tr' : 'en'),
            style: TextStyle(
                fontSize: 12, color: cs.onSurface.withValues(alpha: 0.45)),
          ),
        ],
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PostDetailScreen(postId: item.postId)),
      ),
    );
  }
}
