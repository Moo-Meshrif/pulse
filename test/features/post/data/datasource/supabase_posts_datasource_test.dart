import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pulse/features/post/data/datasource/posts_datasource.dart';
import 'package:pulse/features/post/data/enums/media_type.dart';
import 'package:pulse/features/post/data/enums/mood_kind.dart';
import 'package:pulse/features/post/data/model/post_media_model.dart';
import 'package:pulse/features/post/data/model/post_tag_model.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';

import '../../../../helpers/backend_double.dart';

void main() {
  Future<BackendDouble> signedIn(
    Future<http.Response> Function(http.Request request) handler,
  ) async {
    final backend = BackendDouble((request) {
      if (request.url.path.endsWith('/token')) {
        return Future.value(BackendDouble.sessionResponse());
      }
      return handler(request);
    });
    await backend.signIn();
    return backend;
  }

  Map<String, dynamic> body(http.Request request) =>
      jsonDecode(request.body) as Map<String, dynamic>;

  Map<String, dynamic> row(int n) => {
    'id': 'p$n',
    'author_id': 'a1',
    'username': 'dip',
    'full_name': 'Dip',
    'avatar_url': null,
    'caption': 'Hello',
    'location': 'Cairo',
    'like_count': 3,
    'comment_count': 1,
    'comments_enabled': true,
    'created_at': '2026-10-13T10:0$n:00Z',
    'liked_by_me': false,
    'saved_by_me': true,
    'media': [
      {
        'position': 0,
        'type': 'video',
        'path': 'a1/p$n/0.mp4',
        'thumb_path': 'a1/p$n/0_thumb.jpg',
        'width': 1080,
        'height': 1350,
        'duration_ms': 9000,
        'blurhash': 'LEHV6n',
      },
    ],
  };

  group('getHomeFeed', () {
    test('first page sends only the limit and parses the rows', () async {
      final backend = await signedIn((_) async => BackendDouble.json([row(1)]));
      final posts = SupabasePostsDatasource(backend.client);

      final page = await posts.getHomeFeed(limit: 20);

      expect(body(backend.to('/rpc/home_feed').single), {'p_limit': 20});
      final post = page.posts.single;
      expect(post.id, 'p1');
      expect(post.savedByMe, isTrue);
      expect(post.media!.single.type, MediaType.video);
      expect(post.media!.single.durationMs, 9000);
    });

    test('sends the cursor of the page before', () async {
      final backend = await signedIn((_) async => BackendDouble.json([]));
      final posts = SupabasePostsDatasource(backend.client);

      await posts.getHomeFeed(
        limit: 2,
        beforeCreated: DateTime.utc(2026, 10, 13, 10),
        beforeId: 'p9',
      );

      expect(body(backend.to('/rpc/home_feed').single), {
        'p_limit': 2,
        'p_before_created': '2026-10-13T10:00:00.000Z',
        'p_before_id': 'p9',
      });
    });

    test('a full page carries the cursor of its last post', () async {
      final backend = await signedIn(
        (_) async => BackendDouble.json([row(2), row(1)]),
      );
      final posts = SupabasePostsDatasource(backend.client);

      final page = await posts.getHomeFeed(limit: 2);

      expect(page.nextBeforeId, 'p1');
      expect(page.nextBeforeCreated, DateTime.utc(2026, 10, 13, 10, 1));
    });

    test('a short page has no next cursor', () async {
      final backend = await signedIn((_) async => BackendDouble.json([row(1)]));
      final posts = SupabasePostsDatasource(backend.client);

      final page = await posts.getHomeFeed(limit: 2);

      expect(page.nextBeforeId, isNull);
      expect(page.nextBeforeCreated, isNull);
    });
  });

  test(
    'signMediaUrls returns the links by path and skips the ones that fail',
    () async {
      final backend = await signedIn(
        (_) async => BackendDouble.json([
          {
            'path': 'a/0.jpg',
            'signedURL': '/object/sign/post-media/a/0.jpg?token=t',
            'error': null,
          },
          {'path': 'a/1.jpg', 'signedURL': null, 'error': 'Object not found'},
        ]),
      );
      final posts = SupabasePostsDatasource(backend.client);

      final urls = await posts.signMediaUrls(['a/0.jpg', 'a/1.jpg']);

      expect(urls.keys, ['a/0.jpg']);
      expect(urls['a/0.jpg'], contains('token=t'));
    },
  );

  test('signMediaUrls with no paths makes no request', () async {
    final backend = await signedIn((_) async => BackendDouble.json([]));
    final posts = SupabasePostsDatasource(backend.client);

    expect(await posts.signMediaUrls([]), isEmpty);
    expect(backend.requests, isEmpty);
  });

  test('createPost sends a short as its kind', () async {
    final backend = await signedIn((_) async => BackendDouble.json('s1'));
    final posts = SupabasePostsDatasource(backend.client);

    await posts.createPost(
      id: 's1',
      kind: ContentKind.short,
      commentsEnabled: true,
      visibility: ContentAudience.public,
      media: const [
        PostMediaModel(
          type: MediaType.video,
          path: 'user-1/s1/0.mp4',
          thumbPath: 'user-1/s1/0_thumb.jpg',
          width: 1080,
          height: 1920,
          durationMs: 30000,
        ),
      ],
    );

    expect(body(backend.requests.single)['p_kind'], 'short');
  });

  test(
    'createPost sends one create_post call with the media in order',
    () async {
      final backend = await signedIn((_) async => BackendDouble.json('p1'));
      final posts = SupabasePostsDatasource(backend.client);

      await posts.createPost(
        id: 'p1',
        caption: 'Hello',
        location: 'Cairo',
        commentsEnabled: false,
        visibility: ContentAudience.onlyMe,
        media: const [
          PostMediaModel(
            type: MediaType.image,
            path: 'user-1/p1/0.jpg',
            width: 1080,
            height: 1350,
          ),
          PostMediaModel(
            type: MediaType.video,
            path: 'user-1/p1/1.mp4',
            thumbPath: 'user-1/p1/1_thumb.jpg',
            width: 720,
            height: 1280,
            durationMs: 5000,
            blurhash: 'LEHV6n',
          ),
        ],
      );

      final sent = body(backend.to('/rpc/create_post').single);
      expect(sent['p_id'], 'p1');
      expect(sent['p_kind'], 'post');
      expect(sent['p_caption'], 'Hello');
      expect(sent['p_location'], 'Cairo');
      expect(sent['p_comments_enabled'], isFalse);
      expect(sent['p_visibility'], 'only_me');
      final media = (sent['p_media'] as List).cast<Map<String, dynamic>>();
      expect(media.map((m) => m['path']), [
        'user-1/p1/0.jpg',
        'user-1/p1/1.mp4',
      ]);
      expect(media[1], {
        'type': 'video',
        'path': 'user-1/p1/1.mp4',
        'thumb_path': 'user-1/p1/1_thumb.jpg',
        'width': 720,
        'height': 1280,
        'duration_ms': 5000,
        'blurhash': 'LEHV6n',
      });
    },
  );

  test('a feed row carries the mood, the tags and who tagged you', () async {
    final backend = await signedIn(
      (_) async => BackendDouble.json([
        {
          ...row(1),
          'mood_kind': 'feeling',
          'mood_key': 'happy',
          'mood_text': null,
          'tag_count': 3,
          'i_am_tagged': true,
          'tags': [
            {
              'user_id': 'u2',
              'username': 'sara',
              'full_name': 'Sara Ali',
              'media_position': 1,
              'x': 0.25,
              'y': 1,
            },
            {'user_id': 'u3', 'username': 'omar'},
          ],
        },
      ]),
    );
    final posts = SupabasePostsDatasource(backend.client);

    final post = (await posts.getHomeFeed(limit: 20)).posts.single;

    expect(post.moodKind, MoodKind.feeling);
    expect(post.moodKey, 'happy');
    expect(post.moodText, isNull);
    expect(post.tagCount, 3);
    expect(post.iAmTagged, isTrue);
    expect(post.tags, const [
      PostTagModel(
        userId: 'u2',
        username: 'sara',
        fullName: 'Sara Ali',
        mediaPosition: 1,
        x: 0.25,
        y: 1,
      ),
      PostTagModel(userId: 'u3', username: 'omar'),
    ]);
  });

  test('a row without the new columns reads as no mood and no tags', () async {
    final backend = await signedIn((_) async => BackendDouble.json([row(1)]));
    final posts = SupabasePostsDatasource(backend.client);

    final post = (await posts.getHomeFeed(limit: 20)).posts.single;

    expect(post.moodKind, isNull);
    expect(post.tags, isNull);
    expect(post.iAmTagged, isNull);
  });

  test('createPost and updatePost send the mood and the tags', () async {
    final backend = await signedIn((_) async => BackendDouble.json(null));
    final posts = SupabasePostsDatasource(backend.client);
    const tags = [
      PostTagModel(userId: 'u2', username: 'ignored'),
      PostTagModel(userId: 'u3', mediaPosition: 0, x: 0.5, y: 0.4),
    ];

    await posts.createPost(
      id: 'p1',
      commentsEnabled: true,
      visibility: ContentAudience.public,
      media: const [],
      moodKind: MoodKind.activity,
      moodKey: 'watching',
      moodText: 'a film',
      tags: tags,
    );
    await posts.updatePost(id: 'p1', media: const []);

    final created = body(backend.to('/rpc/create_post').single);
    expect(created['p_mood_kind'], 'activity');
    expect(created['p_mood_key'], 'watching');
    expect(created['p_mood_text'], 'a film');
    expect(created['p_tags'], [
      {'user_id': 'u2', 'media_position': null, 'x': null, 'y': null},
      {'user_id': 'u3', 'media_position': 0, 'x': 0.5, 'y': 0.4},
    ]);
    final updated = body(backend.to('/rpc/update_post').single);
    expect(updated['p_mood_kind'], isNull);
    expect(updated['p_tags'], isEmpty);
  });
}
