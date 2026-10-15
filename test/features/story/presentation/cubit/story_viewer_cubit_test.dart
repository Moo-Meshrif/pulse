import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/enums/report_reason.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/events/event_bus.dart';
import 'package:pulse/core/services/gallery_service.dart';
import 'package:pulse/features/story/data/datasource/stories_datasource.dart';
import 'package:pulse/features/story/data/model/story_model.dart';
import 'package:pulse/features/story/domain/entity/story_rail_item_entity.dart';
import 'package:pulse/features/story/domain/event/story_rail_changed.dart';
import 'package:pulse/features/story/domain/use_case/get_story_rail_use_case.dart';
import 'package:pulse/features/story/presentation/cubit/story_viewer_cubit.dart';
import 'package:pulse/features/story/presentation/utils/enums/story_pause_reason.dart';
import 'package:pulse/features/story/presentation/utils/enums/story_viewer_status.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/data/enums/mute_scope.dart';

import '../../../../helpers/content_mocks.dart';

class _Rail extends Mock implements GetStoryRailUseCase {}

class _Stories extends Mock implements StoriesDatasource {}

class _Gallery extends Mock implements GalleryService {}

StoryRailItemEntity person(String id, {bool isMe = false}) =>
    StoryRailItemEntity(
      authorId: id,
      username: id,
      isMe: isMe,
      storyCount: 2,
      allSeen: false,
    );

StoryModel story(String id, {bool seen = false, bool liked = false}) =>
    StoryModel(id: id, seenByMe: seen, likedByMe: liked);

void main() {
  late _Rail rail;
  late _Stories stories;
  late _Gallery gallery;
  late MockSetMute setMute;
  late MockReportContent reportContent;
  late MockRemoveMediaFiles removeFiles;
  late EventBus bus;

  StoryViewerCubit build() => StoryViewerCubit(
    rail,
    stories,
    gallery,
    setMute,
    reportContent,
    removeFiles,
    bus,
  );

  setUp(() {
    bus = EventBus();
    rail = _Rail();
    stories = _Stories();
    gallery = _Gallery();
    setMute = okSetMute();
    reportContent = okReportContent();
    removeFiles = okRemoveMediaFiles();
    registerFallbackValue(const StoryModel());
    registerContentFallbacks();
    when(() => rail()).thenAnswer(
      (_) async => [person('a'), person('b'), person('c', isMe: true)],
    );
    when(() => stories.getAuthorStories('a')).thenAnswer(
      (_) async => [story('a1', seen: true), story('a2'), story('a3')],
    );
    when(() => stories.getAuthorStories('b'))
        .thenAnswer((_) async => [story('b1')]);
    when(() => stories.getAuthorStories('c'))
        .thenAnswer((_) async => [story('c1')]);
    when(() => stories.markViewed(any())).thenAnswer((_) async {});
    when(() => stories.setLiked(any(), liked: any(named: 'liked')))
        .thenAnswer((_) async {});
  });

  group('load', () {
    test('opens at the person and their first unseen story', () async {
      final cubit = build();
      await cubit.load('a');
      expect(cubit.state.status, StoryViewerStatus.ready);
      expect(cubit.state.personIndex, 0);
      expect(cubit.state.storyIndex, 1);
      expect(cubit.state.story!.id, 'a2');
      await cubit.close();
    });

    test('starts at a later person of the rail', () async {
      final cubit = build();
      await cubit.load('b');
      expect(cubit.state.personIndex, 1);
      expect(cubit.state.story!.id, 'b1');
      await cubit.close();
    });

    test('loads the next person ahead of time', () async {
      final cubit = build();
      await cubit.load('a');
      await pumpEventQueue();
      verify(() => stories.getAuthorStories('b')).called(1);
      expect(cubit.state.stories.keys, containsAll(['a', 'b']));
      await cubit.close();
    });

    test('a person who is not on the rail closes the viewer', () async {
      final cubit = build();
      await cubit.load('zzz');
      expect(cubit.state.isFinished, isTrue);
      await cubit.close();
    });

    test('a rail failure is a failed viewer, and retry loads again', () async {
      when(() => rail()).thenThrow(const NetworkFailure());
      final cubit = build();
      await cubit.load('a');
      expect(cubit.state.status, StoryViewerStatus.failed);
      expect(cubit.state.failure, const NetworkFailure());

      when(() => rail()).thenAnswer((_) async => [person('a')]);
      await cubit.retry('a');
      expect(cubit.state.status, StoryViewerStatus.ready);
      await cubit.close();
    });

    test('a person whose stories fail can be retried', () async {
      when(() => stories.getAuthorStories('a'))
          .thenThrow(const NetworkFailure());
      final cubit = build();
      await cubit.load('a');
      expect(cubit.state.failedAuthors, {'a'});
      expect(cubit.state.story, isNull);

      when(() => stories.getAuthorStories('a'))
          .thenAnswer((_) async => [story('a1')]);
      await cubit.retryPerson('a');
      expect(cubit.state.failedAuthors, isEmpty);
      expect(cubit.state.story!.id, 'a1');
      await cubit.close();
    });

    test('a person whose stories all expired is skipped', () async {
      when(() => stories.getAuthorStories('a')).thenAnswer((_) async => []);
      final cubit = build();
      await cubit.load('a');
      expect(cubit.state.personIndex, 1);
      await cubit.close();
    });
  });

  group('moving', () {
    late StoryViewerCubit cubit;

    setUp(() async {
      cubit = build();
      await cubit.load('a'); // a2
      await pumpEventQueue();
    });

    tearDown(() => cubit.close());

    test('next goes through the stories, then the next person', () async {
      await cubit.next();
      expect(cubit.state.story!.id, 'a3');
      await cubit.next();
      expect(cubit.state.personIndex, 1);
      expect(cubit.state.story!.id, 'b1');
    });

    test('after the last person the viewer finishes', () async {
      await cubit.showPerson(2);
      await cubit.next();
      expect(cubit.state.isFinished, isTrue);
    });

    test(
      'previous goes back, then to the person before from their start',
      () async {
        await cubit.previous();
        expect(cubit.state.story!.id, 'a1');
        await cubit.showPerson(1);
        await cubit.previous();
        expect(cubit.state.personIndex, 0);
        expect(cubit.state.storyIndex, 0);
      },
    );

    test('previous on the very first story starts it again', () async {
      await cubit.previous(); // a1
      final before = cubit.state.restarts;
      await cubit.previous();
      expect(cubit.state.restarts, before + 1);
      expect(cubit.state.story!.id, 'a1');
    });

    test('showPerson opens that person at their first unseen story', () async {
      await cubit.showPerson(1);
      expect(cubit.state.personIndex, 1);
      expect(cubit.state.story!.id, 'b1');
      await cubit.showPerson(99);
      expect(cubit.state.personIndex, 1);
    });
  });

  group('pausing', () {
    test('plays only when no reason applies', () async {
      final cubit = build();
      await cubit.load('a');
      expect(cubit.state.isPaused, isFalse);
      cubit.pause(StoryPauseReason.hold);
      cubit.pause(StoryPauseReason.keyboard);
      expect(cubit.state.isHolding, isTrue);
      cubit.resume(StoryPauseReason.hold);
      expect(cubit.state.isPaused, isTrue);
      expect(cubit.state.isHolding, isFalse);
      cubit.resume(StoryPauseReason.keyboard);
      expect(cubit.state.isPaused, isFalse);
      await cubit.close();
    });
  });

  group('seen', () {
    test('a story is marked after one second on screen', () {
      fakeAsync((async) {
        final cubit = build();
        cubit.load('a');
        async.flushMicrotasks();

        async.elapse(const Duration(milliseconds: 999));
        verifyNever(() => stories.markViewed(any()));
        async.elapse(const Duration(milliseconds: 2));
        verify(() => stories.markViewed('a2')).called(1);
        expect(cubit.state.story!.seenByMe, isTrue);

        async.elapse(const Duration(seconds: 5));
        verifyNever(() => stories.markViewed('a2')); // not again
        cubit.close();
      });
    });

    test('a story that is skipped before a second is not marked', () {
      fakeAsync((async) {
        final cubit = build();
        cubit.load('a');
        async.flushMicrotasks();
        async.elapse(const Duration(milliseconds: 600));
        cubit.next(); // a3
        async.flushMicrotasks();
        async.elapse(const Duration(milliseconds: 600));
        verifyNever(() => stories.markViewed(any()));
        async.elapse(const Duration(milliseconds: 500));
        verify(() => stories.markViewed('a3')).called(1);
        verifyNever(() => stories.markViewed('a2'));
        cubit.close();
      });
    });

    test('a paused story is not marked until it plays again', () {
      fakeAsync((async) {
        final cubit = build();
        cubit.load('a');
        async.flushMicrotasks();
        cubit.pause(StoryPauseReason.hold);
        async.elapse(const Duration(seconds: 5));
        verifyNever(() => stories.markViewed(any()));
        cubit.resume(StoryPauseReason.hold);
        async.elapse(const Duration(seconds: 1));
        verify(() => stories.markViewed('a2')).called(1);
        cubit.close();
      });
    });

    test('your own story is never marked', () {
      fakeAsync((async) {
        final cubit = build();
        cubit.load('c');
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 3));
        verifyNever(() => stories.markViewed(any()));
        cubit.close();
      });
    });

    test('a failed mark does not interrupt the viewer', () {
      when(() => stories.markViewed(any())).thenThrow(const NetworkFailure());
      fakeAsync((async) {
        final cubit = build();
        cubit.load('a');
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 2));
        expect(cubit.state.status, StoryViewerStatus.ready);
        cubit.close();
      });
    });
  });

  group('like', () {
    test('shows at once and is sent', () async {
      final cubit = build();
      await cubit.load('a');
      final gate = Completer<void>();
      when(() => stories.setLiked('a2', liked: true))
          .thenAnswer((_) => gate.future);

      final done = cubit.toggleLike();
      expect(cubit.state.story!.likedByMe, isTrue);
      gate.complete();
      await done;
      expect(cubit.state.story!.likedByMe, isTrue);
      verify(() => stories.setLiked('a2', liked: true)).called(1);
      await cubit.close();
    });

    test('takes a like back', () async {
      when(() => stories.getAuthorStories('a'))
          .thenAnswer((_) async => [story('a1', liked: true)]);
      final cubit = build();
      await cubit.load('a');
      await cubit.toggleLike();
      expect(cubit.state.story!.likedByMe, isFalse);
      verify(() => stories.setLiked('a1', liked: false)).called(1);
      await cubit.close();
    });

    test('goes back when the call fails', () async {
      when(() => stories.setLiked(any(), liked: any(named: 'liked')))
          .thenThrow(const NetworkFailure());
      final cubit = build();
      await cubit.load('a');
      await cubit.toggleLike();
      expect(cubit.state.story!.likedByMe, isFalse);
      await cubit.close();
    });
  });

  group('mute', () {
    test('hides the person and moves on to the next', () async {
      when(
        () => setMute(
          any(),
          muted: any(named: 'muted'),
          scope: any(named: 'scope'),
        ),
      ).thenAnswer((_) async {
        return;
      });
      final cubit = build();
      await cubit.load('a');
      final railChanges = expectLater(
        bus.on<StoryRailChanged>(),
        emits(const StoryRailChanged()),
      );
      final failure = await cubit.muteCurrent();
      expect(failure, isNull);
      await railChanges;
      verify(() => setMute('a', muted: true, scope: MuteScope.stories))
          .called(1);
      expect(cubit.state.people.map((p) => p.authorId), ['b', 'c']);
      expect(cubit.state.person!.authorId, 'b');
      expect(cubit.state.story!.id, 'b1');
      await cubit.close();
    });

    test('muting the last person closes the viewer', () async {
      when(
        () => setMute(
          any(),
          muted: any(named: 'muted'),
          scope: any(named: 'scope'),
        ),
      ).thenAnswer((_) async {
        return;
      });
      final cubit = build();
      await cubit.load('c');
      await cubit.muteCurrent();
      expect(cubit.state.isFinished, isTrue);
      await cubit.close();
    });

    test('a failure keeps the person and is returned', () async {
      when(
        () => setMute(
          any(),
          muted: any(named: 'muted'),
          scope: any(named: 'scope'),
        ),
      ).thenThrow(const NetworkFailure());
      final cubit = build();
      await cubit.load('a');
      expect(await cubit.muteCurrent(), const NetworkFailure());
      expect(cubit.state.people, hasLength(3));
      await cubit.close();
    });

    test(
      'Undo brings the person back at their place, on their first story',
      () async {
        when(
          () => setMute(
            any(),
            muted: any(named: 'muted'),
            scope: any(named: 'scope'),
          ),
        ).thenAnswer((_) async {
          return;
        });
        final cubit = build();
        await cubit.load('a');
        await cubit.muteCurrent();
        expect(cubit.state.people.map((p) => p.authorId), ['b', 'c']);
        expect(cubit.state.person!.authorId, 'b');

        expect(await cubit.unmute('a'), isNull);
        await pumpEventQueue();

        expect(cubit.state.people.map((p) => p.authorId), ['a', 'b', 'c']);
        expect(cubit.state.person!.authorId, 'a');
        expect(cubit.state.storyIndex, 0);
        expect(cubit.state.story!.id, 'a1');
        await cubit.close();
      },
    );

    test(
      'Undo of someone in the middle goes back between the same two',
      () async {
        when(
          () => setMute(
            any(),
            muted: any(named: 'muted'),
            scope: any(named: 'scope'),
          ),
        ).thenAnswer((_) async {
          return;
        });
        final cubit = build();
        await cubit.load('b');
        await cubit.muteCurrent();
        await cubit.unmute('b');
        await pumpEventQueue();
        expect(cubit.state.people.map((p) => p.authorId), ['a', 'b', 'c']);
        expect(cubit.state.person!.authorId, 'b');
        await cubit.close();
      },
    );

    test('Undo after the viewer closed changes nothing on screen', () async {
      when(
        () => setMute(
          any(),
          muted: any(named: 'muted'),
          scope: any(named: 'scope'),
        ),
      ).thenAnswer((_) async {
        return;
      });
      final cubit = build();
      await cubit.load('c');
      await cubit.muteCurrent(); // the last person: the viewer closes
      expect(cubit.state.isFinished, isTrue);
      await cubit.unmute('c');
      expect(cubit.state.people.map((p) => p.authorId), ['a', 'b']);
      await cubit.close();
    });

    test('a failed Undo keeps the person out', () async {
      when(() => setMute(any(), muted: true, scope: any(named: 'scope')))
          .thenAnswer((_) async {
            return;
          });
      when(() => setMute(any(), muted: false, scope: any(named: 'scope')))
          .thenThrow(const NetworkFailure());
      final cubit = build();
      await cubit.load('a');
      await cubit.muteCurrent();
      expect(await cubit.unmute('a'), const NetworkFailure());
      expect(cubit.state.people.map((p) => p.authorId), ['b', 'c']);
      await cubit.close();
    });

    test('unmute sends muted: false', () async {
      when(
        () => setMute(
          any(),
          muted: any(named: 'muted'),
          scope: any(named: 'scope'),
        ),
      ).thenAnswer((_) async {
        return;
      });
      final cubit = build();
      expect(await cubit.unmute('a'), isNull);
      verify(() => setMute('a', muted: false, scope: MuteScope.stories))
          .called(1);
      await cubit.close();
    });
  });

  group('delete', () {
    test('removes the files of the story after the row', () async {
      when(() => stories.getAuthorStories('a')).thenAnswer(
        (_) async => [
          story('a1', seen: true),
          const StoryModel(
            id: 'a2',
            path: 'u/stories/a2.jpg',
            thumbPath: 'u/stories/a2_t.jpg',
          ),
        ],
      );
      when(() => stories.deleteStory(any())).thenAnswer((_) async {});
      final cubit = build();
      await cubit.load('a'); // a2
      await cubit.commitDelete(cubit.deleteCurrent()!);
      verifyInOrder([
        () => stories.deleteStory(any()),
        () => removeFiles(['u/stories/a2.jpg', 'u/stories/a2_t.jpg']),
      ]);
      await cubit.close();
    });

    test('a failed delete keeps the files', () async {
      when(() => stories.deleteStory(any())).thenThrow(const NetworkFailure());
      final cubit = build();
      await cubit.load('c');
      await cubit.commitDelete(cubit.deleteCurrent()!);
      verifyNever(() => removeFiles(any()));
      await cubit.close();
    });

    test('shows the story that takes its place', () async {
      when(() => stories.deleteStory(any())).thenAnswer((_) async {});
      final cubit = build();
      await cubit.load('a'); // a2
      cubit.deleteCurrent();
      verifyNever(() => stories.deleteStory(any()));
      expect(cubit.state.currentStories!.map((s) => s.id), ['a1', 'a3']);
      expect(cubit.state.story!.id, 'a3');
      expect(cubit.state.isFinished, isFalse);
      await cubit.close();
    });

    test(
      'after the last story deleted, falls back to the one before',
      () async {
        when(() => stories.deleteStory(any())).thenAnswer((_) async {});
        final cubit = build();
        await cubit.load('a');
        await cubit.next(); // a3
        cubit.deleteCurrent();
        expect(cubit.state.story!.id, 'a2');
        await cubit.close();
      },
    );

    test('deleting the only story closes the viewer', () async {
      when(() => stories.deleteStory(any())).thenAnswer((_) async {});
      final cubit = build();
      await cubit.load('c');
      cubit.deleteCurrent();
      expect(cubit.state.isFinished, isTrue);
      await cubit.close();
    });

    test(
      'a failed commit puts the story back and returns the failure',
      () async {
        when(() => stories.deleteStory(any()))
            .thenThrow(const NetworkFailure());
        final cubit = build();
        await cubit.load('a');
        await cubit.next(); // a3
        final id = cubit.deleteCurrent()!;
        expect(await cubit.commitDelete(id), const NetworkFailure());
        expect(cubit.state.story!.id, 'a3');
        await cubit.close();
      },
    );

    test('Undo puts the story back at its place and sends nothing', () async {
      final cubit = build();
      await cubit.load('a'); // a2
      final id = cubit.deleteCurrent()!;
      cubit.undoDelete(id);
      expect(cubit.state.currentStories!.map((s) => s.id), ['a1', 'a2', 'a3']);
      expect(cubit.state.story!.id, 'a2');
      verifyNever(() => stories.deleteStory(any()));
      await cubit.close();
    });
  });

  group('report and save', () {
    test(
      'report passes the reason and note; a failure reaches the sheet',
      () async {
        final cubit = build();
        await cubit.report('a2', ReportReason.other, 'rude');
        verify(
          () => reportContent(
            ContentKind.story,
            'a2',
            ReportReason.other,
            note: 'rude',
          ),
        ).called(1);

        when(() => reportContent(any(), any(), any(), note: any(named: 'note')))
            .thenThrow(const NetworkFailure());
        await expectLater(
          cubit.report('a2', ReportReason.spam, null),
          throwsA(const NetworkFailure()),
        );
        await cubit.close();
      },
    );

    test('after a sent report the viewer goes to the next story', () async {
      final cubit = build();
      await cubit.load('a'); // a2
      await cubit.skipReported();
      expect(cubit.state.story!.id, 'a3');
      await cubit.close();
    });

    test('save returns the failure, or null', () async {
      when(() => gallery.saveVideoFromUrl(any())).thenAnswer((_) async {});
      final cubit = build();
      expect(await cubit.saveVideo('https://x/v.mp4'), isNull);

      when(() => gallery.saveVideoFromUrl(any()))
          .thenThrow(const PermissionFailure());
      expect(
        await cubit.saveVideo('https://x/v.mp4'),
        const PermissionFailure(),
      );
      await cubit.close();
    });
  });
}
