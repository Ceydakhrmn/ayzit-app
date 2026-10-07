import 'package:ayzit_app/models/activity_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('kimlikler kurallardaki biçimle aynı', () {
    expect(ActivityItem.likeId('post1', 'userB'), 'like_post1_userB');
    expect(ActivityItem.commentDocId('cmt9'), 'comment_cmt9');
  });

  test('beğeni kaydı yalnızca izin verilen alanları taşır', () {
    final m = ActivityItem.likeMap(
        postId: 'p', actorId: 'u', actorUsername: 'bku');
    expect(m.keys.toSet(), {
      'type', 'actorId', 'actorUsername', 'postId', 'createdAt', 'read',
      'pushed',
    });
    expect(m['type'], 'like');
    expect(m['read'], isFalse);
    expect(m['pushed'], isFalse);
    expect(m['createdAt'], isA<FieldValue>());
  });

  test('uzun yorum 120 karaktere kısaltılır', () {
    final m = ActivityItem.commentMap(
      postId: 'p',
      commentId: 'c',
      actorId: 'u',
      actorUsername: 'bku',
      text: 'a' * 300,
    );
    final text = m['text'] as String;
    expect(text.length, ActivityItem.maxTextLength);
    expect(text.endsWith('…'), isTrue);
    expect(m['commentId'], 'c');
  });

  test('kısa yorum olduğu gibi kalır', () {
    final m = ActivityItem.commentMap(
      postId: 'p',
      commentId: 'c',
      actorId: 'u',
      actorUsername: 'bku',
      text: 'Çok güzel',
    );
    expect(m['text'], 'Çok güzel');
  });
}
