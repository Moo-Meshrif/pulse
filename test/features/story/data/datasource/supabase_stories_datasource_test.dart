import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/story/data/datasource/stories_datasource.dart';
import 'package:pulse/features/story/data/enums/audience_list.dart';
import 'package:pulse/features/story/data/enums/audience_tab.dart';
import 'package:pulse/features/story/data/enums/story_media_type.dart';
import 'package:pulse/features/story/data/enums/story_overlay_type.dart';
import 'package:pulse/features/story/data/model/new_story_model.dart';
import 'package:pulse/features/story/data/model/story_model.dart';
import 'package:pulse/features/story/data/model/story_overlay_model.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';

import '../../../../helpers/backend_double.dart';

void main() {
  Future<Failure?> failureOf(Future<Object?> call) async {
    try {
      await call;
    } on Failure catch (failure) {
      return failure;
    }
    return null;
  }

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

  Map<String, dynamic> storyRow(String id, {String? thumb}) => {
    'id': id,
    'type': thumb == null ? 'image' : 'video',
    'path': 'user-1/stories/$id.jpg',
    'thumb_path': thumb,
    'width': 1080,
    'height': 1920,
    'duration_ms': thumb == null ? null : 12000,
    'blurhash': null,
    'overlays': [
      {
        'type': 'text',
        'text': 'Hi',
        'x': 0.5,
        'y': 0.4,
        'scale': 1,
        'rotation': -4.0,
        'color': '#FFFFFF',
      },
    ],
    'created_at': '2026-10-13T10:00:00Z',
    'expires_at': '2026-10-14T10:00:00Z',
    'seen_by_me': true,
    'liked_by_me': false,
    'view_count': null,
  };

  group('getStoryRail', () {
    test('calls story_rail with the limit and reads each row', () async {
      final backend = await signedIn(
        (_) async => BackendDouble.json([
          {
            'author_id': 'a1',
            'username': 'nour',
            'full_name': 'Nour',
            'avatar_url': null,
            'is_me': false,
            'story_count': 3,
            'latest_at': '2026-10-13T10:00:00Z',
            'all_seen': true,
          },
        ]),
      );
      final rail = await SupabaseStoriesDatasource(backend.client)
          .getStoryRail(limit: 10);

      expect(body(backend.to('/rpc/story_rail').single), {'p_limit': 10});
      expect(rail.single.authorId, 'a1');
      expect(rail.single.storyCount, 3);
      expect(rail.single.allSeen, isTrue);
      expect(rail.single.latestAt, DateTime.utc(2026, 10, 13, 10));
    });

    test('offline-style failures become a Failure', () async {
      final backend = await signedIn(
        (_) async => BackendDouble.postgrestError(500, 'XX000'),
      );
      expect(
        await failureOf(
          SupabaseStoriesDatasource(backend.client).getStoryRail(),
        ),
        isA<ServerFailure>(),
      );
    });
  });

  group('getAuthorStories', () {
    test('asks for the author and signs the media and poster paths', () async {
      final backend = await signedIn((request) async {
        if (request.url.path.endsWith('/rpc/author_stories')) {
          return BackendDouble.json([
            storyRow('s1'),
            storyRow('s2', thumb: 'user-1/stories/s2_thumb.jpg'),
          ]);
        }
        return BackendDouble.json([
          for (final p in body(request)['paths'] as List)
            {'path': p, 'signedURL': '/object/sign/post-media/$p?token=t'},
        ]);
      });
      final stories = await SupabaseStoriesDatasource(backend.client)
          .getAuthorStories('a1');

      expect(body(backend.to('/rpc/author_stories').single), {
        'p_author': 'a1',
      });
      final sign = backend.to('/object/sign/post-media').single;
      expect(body(sign)['expiresIn'], 3600);
      expect(body(sign)['paths'], [
        'user-1/stories/s1.jpg',
        'user-1/stories/s2.jpg',
        'user-1/stories/s2_thumb.jpg',
      ]);

      expect(stories.map((s) => s.id), ['s1', 's2']);
      expect(stories[0].type, StoryMediaType.image);
      expect(stories[0].mediaUrl, contains('s1.jpg?token=t'));
      expect(stories[0].thumbUrl, isNull);
      expect(stories[1].type, StoryMediaType.video);
      expect(stories[1].durationMs, 12000);
      expect(stories[1].thumbUrl, contains('s2_thumb.jpg?token=t'));
      expect(stories[0].overlays!.single.type, StoryOverlayType.text);
      expect(stories[0].overlays!.single.x, 0.5);
      expect(stories[0].seenByMe, isTrue);
    });

    test('no stories means no signing request', () async {
      final backend = await signedIn((_) async => BackendDouble.json([]));
      final stories = await SupabaseStoriesDatasource(backend.client)
          .getAuthorStories('a1');
      expect(stories, isEmpty);
      expect(backend.to('/object/sign/post-media'), isEmpty);
    });
  });

  test('markViewed upserts the view and ignores a duplicate', () async {
    final backend = await signedIn((_) async => BackendDouble.json([]));
    await SupabaseStoriesDatasource(backend.client).markViewed('s1');

    final request = backend.to('/story_views').single;
    expect(request.method, 'POST');
    expect(request.url.queryParameters['on_conflict'], 'story_id,viewer_id');
    expect(request.headers['Prefer'], contains('resolution=ignore-duplicates'));
    expect(body(request), {'story_id': 's1'});
  });

  test('setLiked calls set_story_like', () async {
    final backend = await signedIn((_) async => BackendDouble.json(true));
    await SupabaseStoriesDatasource(backend.client).setLiked('s1', liked: true);
    expect(body(backend.to('/rpc/set_story_like').single), {
      'p_story': 's1',
      'p_liked': true,
    });
  });

  group('getViewers', () {
    test('the first page has no cursor', () async {
      final backend = await signedIn(
        (_) async => BackendDouble.json([
          {
            'user_id': 'u1',
            'username': 'sara',
            'full_name': null,
            'avatar_url': null,
            'viewed_at': '2026-10-13T11:00:00Z',
            'liked': true,
            'total': 24,
          },
        ]),
      );
      final viewers = await SupabaseStoriesDatasource(backend.client)
          .getViewers('s1', limit: 30);

      expect(body(backend.to('/rpc/story_viewers').single), {
        'p_story': 's1',
        'p_limit': 30,
      });
      expect(viewers.single.liked, isTrue);
      expect(viewers.single.total, 24);
    });

    test('the next page sends the last viewed_at as p_before', () async {
      final backend = await signedIn((_) async => BackendDouble.json([]));
      await SupabaseStoriesDatasource(backend.client)
          .getViewers('s1', limit: 30, before: DateTime.utc(2026, 10, 13, 11));
      expect(
        body(backend.to('/rpc/story_viewers').single)['p_before'],
        '2026-10-13T11:00:00.000Z',
      );
    });

    test('a story that is not yours is a failure', () async {
      final backend = await signedIn(
        (_) async => BackendDouble.postgrestError(403, '42501'),
      );
      expect(
        await failureOf(
          SupabaseStoriesDatasource(backend.client).getViewers('s1', limit: 30),
        ),
        isA<AuthFailure>(),
      );
    });
  });

  group('railChanges', () {
    test('notifyRailChanged fires it', () async {
      final backend = await signedIn((_) async => BackendDouble.json(true));
      final datasource = SupabaseStoriesDatasource(backend.client);
      var events = 0;
      final sub = datasource.railChanges.listen((_) => events++);
      datasource.notifyRailChanged();
      datasource.notifyRailChanged();
      await Future<void>.delayed(Duration.zero);
      expect(events, 2);
      await sub.cancel();
    });

    test('deleting a story fires it, a failed delete does not', () async {
      final backend = await signedIn((_) async => BackendDouble.json([]));
      final datasource = SupabaseStoriesDatasource(backend.client);
      var events = 0;
      final sub = datasource.railChanges.listen((_) => events++);
      await datasource.deleteStory(const StoryModel(id: 's1'));
      await Future<void>.delayed(Duration.zero);
      expect(events, 1);

      final failing = await signedIn(
        (_) async => BackendDouble.postgrestError(500, 'XX000'),
      );
      final other = SupabaseStoriesDatasource(failing.client);
      var failedEvents = 0;
      final sub2 = other.railChanges.listen((_) => failedEvents++);
      await failureOf(other.deleteStory(const StoryModel(id: 's1')));
      await Future<void>.delayed(Duration.zero);
      expect(failedEvents, 0);
      await sub.cancel();
      await sub2.cancel();
    });
  });

  group('audience', () {
    test('getAudiencePeople sends list, tab, query and the page', () async {
      final backend = await signedIn(
        (_) async => BackendDouble.json([
          {
            'user_id': 'u1',
            'username': 'sara',
            'full_name': 'Sara Ali',
            'avatar_url': null,
            'selected': true,
            'in_other_list': true,
          },
        ]),
      );
      final people = await SupabaseStoriesDatasource(backend.client)
          .getAudiencePeople(
            AudienceList.hiddenFrom,
            tab: AudienceTab.selected,
            query: 'sa',
            limit: 30,
            offset: 60,
          );
      expect(body(backend.to('/rpc/audience_people').single), {
        'p_list': 'hidden',
        'p_tab': 'selected',
        'p_query': 'sa',
        'p_limit': 30,
        'p_offset': 60,
      });
      expect(people.single.fullName, 'Sara Ali');
      expect(people.single.selected, isTrue);
      expect(people.single.isInOtherList, isTrue);
    });

    test('updateAudienceList sends who was added and removed', () async {
      final backend = await signedIn((_) async => BackendDouble.json(null));
      await SupabaseStoriesDatasource(backend.client).updateAudienceList(
        AudienceList.closeFriends,
        add: ['u1', 'u2'],
        remove: ['u3'],
      );
      expect(body(backend.to('/rpc/update_audience_list').single), {
        'p_list': 'close_friends',
        'p_add': ['u1', 'u2'],
        'p_remove': ['u3'],
      });
    });

    test('author_stories rows carry the audience', () {
      expect(
        StoryModel.fromJson({'id': 's1', 'audience': 'close_friends'}).audience,
        ContentAudience.closeFriends,
      );
      expect(StoryModel.fromJson({'id': 's1'}).audience, isNull);
    });
  });

  test('deleteStory deletes the row and leaves the files to core', () async {
    final backend = await signedIn((_) async => BackendDouble.json([]));
    await SupabaseStoriesDatasource(backend.client).deleteStory(
      const StoryModel(
        id: 's1',
        path: 'user-1/stories/s1.mp4',
        thumbPath: 'user-1/stories/s1_thumb.jpg',
      ),
    );

    final row = backend.to('/stories').single;
    expect(row.method, 'DELETE');
    expect(row.url.queryParameters['id'], 'eq.s1');
    expect(backend.to('/object/post-media'), isEmpty);
  });

  test('deleteStory without an id is a not-found failure', () async {
    final backend = await signedIn((_) async => BackendDouble.json([]));
    expect(
      await failureOf(
        SupabaseStoriesDatasource(backend.client)
            .deleteStory(const StoryModel()),
      ),
      isA<NotFoundFailure>(),
    );
    expect(backend.to('/stories'), isEmpty);
  });

  test(
    'insertStory writes the row with the measurements and stickers',
    () async {
      final backend = await signedIn((_) async => BackendDouble.json([]));
      await SupabaseStoriesDatasource(backend.client).insertStory(
        NewStoryModel(
          filePath: '/tmp/a.mp4',
          type: StoryMediaType.video,
          width: 1080,
          height: 1920,
          durationMs: 9000,
          overlays: const [
            StoryOverlayModel(
              type: StoryOverlayType.text,
              text: 'Hi',
              x: 0.5,
              y: 0.4,
              scale: 1,
              rotation: 0,
              color: '#FFFFFF',
            ),
          ],
        ),
        mediaPath: 'user-1/stories/x.mp4',
        thumbPath: 'user-1/stories/x_thumb.jpg',
      );

      final sent = body(backend.to('/stories').single);
      expect(sent['type'], 'video');
      expect(sent['path'], 'user-1/stories/x.mp4');
      expect(sent['thumb_path'], 'user-1/stories/x_thumb.jpg');
      expect(sent['width'], 1080);
      expect(sent['duration_ms'], 9000);
      expect(
        ((sent['overlays'] as List<dynamic>).single
            as Map<String, dynamic>)['text'],
        'Hi',
      );
      expect(sent.containsKey('author_id'), isFalse);
    },
  );

  test(
    'currentUserId is the signed-in user, and a missing session fails',
    () async {
      final backend = await signedIn((_) async => BackendDouble.json([]));
      expect(
        SupabaseStoriesDatasource(backend.client).currentUserId,
        BackendDouble.uid,
      );
      await backend.client.auth.signOut();
      expect(
        () => SupabaseStoriesDatasource(backend.client).currentUserId,
        throwsA(anything),
      );
    },
  );
}
