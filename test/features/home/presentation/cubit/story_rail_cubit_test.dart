import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/events/event_bus.dart';
import 'package:pulse/features/home/presentation/cubit/story_rail_cubit.dart';
import 'package:pulse/features/post/domain/use_case/watch_feed_refresh_requests_use_case.dart';
import 'package:pulse/features/story/domain/entity/story_rail_item_entity.dart';
import 'package:pulse/features/story/domain/entity/story_upload_status.dart';
import 'package:pulse/features/story/domain/use_case/get_story_rail_use_case.dart';
import 'package:pulse/features/story/domain/use_case/retry_story_upload_use_case.dart';
import 'package:pulse/features/story/domain/use_case/watch_story_rail_changes_use_case.dart';
import 'package:pulse/features/story/domain/use_case/watch_story_upload_use_case.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/domain/event/content_delete_event.dart';

class _GetRail extends Mock implements GetStoryRailUseCase {}

class _Changes extends Mock implements WatchStoryRailChangesUseCase {}

class _Upload extends Mock implements WatchStoryUploadUseCase {}

class _Retry extends Mock implements RetryStoryUploadUseCase {}

class _Refresh extends Mock implements WatchFeedRefreshRequestsUseCase {}

StoryRailItemEntity person(String id, {bool isMe = false}) =>
    StoryRailItemEntity(
      authorId: id,
      username: 'user.$id',
      isMe: isMe,
      storyCount: 1,
      allSeen: false,
    );

void main() {
  late _GetRail getRail;
  late _Changes changes;
  late _Upload upload;
  late EventBus bus;
  late _Retry retry;
  late _Refresh refresh;
  late StreamController<void> requests;
  late StreamController<void> railChanges;
  late StreamController<StoryUploadStatus> uploadStatus;

  setUp(() {
    getRail = _GetRail();
    changes = _Changes();
    upload = _Upload();
    bus = EventBus();
    addTearDown(bus.dispose);
    retry = _Retry();
    refresh = _Refresh();
    requests = StreamController<void>.broadcast();
    when(refresh.call).thenAnswer((_) => requests.stream);
    addTearDown(requests.close);
    railChanges = StreamController<void>.broadcast();
    uploadStatus = StreamController<StoryUploadStatus>.broadcast();
    when(getRail.call).thenAnswer((_) async => [person('a')]);
    when(changes.call).thenAnswer((_) => railChanges.stream);
    when(upload.call).thenAnswer((_) => uploadStatus.stream);
    addTearDown(railChanges.close);
    addTearDown(uploadStatus.close);
  });

  StoryRailCubit build() =>
      StoryRailCubit(getRail, changes, bus, upload, retry, refresh);

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  test('starts with the people on the rail', () async {
    final cubit = build();
    await cubit.start();
    expect(cubit.state.items.map((p) => p.authorId), ['a']);
    expect(cubit.state.upload, const StoryUploadIdle());
    await cubit.close();
  });

  test('a load that fails leaves the rail as it is', () async {
    final cubit = build();
    await cubit.start();
    when(getRail.call).thenThrow(const NetworkFailure());
    await cubit.load();
    expect(cubit.state.items, hasLength(1));
    await cubit.close();
  });

  group('a delete that can be undone', () {
    setUp(() {
      when(getRail.call)
          .thenAnswer((_) async => [person('me', isMe: true), person('a')]);
    });

    test('hides your last story at once, without reloading', () async {
      final cubit = build();
      await cubit.start();
      bus.fire(
        const ContentDeleteEvent(
          ContentKind.story,
          's1',
          ContentDeleteStage.pending,
        ),
      );
      await flush();
      expect(cubit.state.items.map((p) => p.authorId), ['a']);
      verify(getRail.call).called(1);
      await cubit.close();
    });

    test('keeps your row with fewer stories while some are left', () async {
      when(getRail.call).thenAnswer(
        (_) async => [
          StoryRailItemEntity(
            authorId: 'me',
            username: 'me',
            isMe: true,
            storyCount: 3,
            allSeen: false,
          ),
        ],
      );
      final cubit = build();
      await cubit.start();
      bus.fire(
        const ContentDeleteEvent(
          ContentKind.story,
          's1',
          ContentDeleteStage.pending,
        ),
      );
      await flush();
      expect(cubit.state.me!.storyCount, 2);
      await cubit.close();
    });

    test('Undo brings it back', () async {
      final cubit = build();
      await cubit.start();
      bus.fire(
        const ContentDeleteEvent(
          ContentKind.story,
          's1',
          ContentDeleteStage.pending,
        ),
      );
      bus.fire(
        const ContentDeleteEvent(
          ContentKind.story,
          's1',
          ContentDeleteStage.restored,
        ),
      );
      await flush();
      expect(cubit.state.items.map((p) => p.authorId), ['me', 'a']);
      await cubit.close();
    });

    test('once deleted it reloads from the server', () async {
      final cubit = build();
      await cubit.start();
      bus.fire(
        const ContentDeleteEvent(
          ContentKind.story,
          's1',
          ContentDeleteStage.pending,
        ),
      );
      when(getRail.call).thenAnswer((_) async => [person('a')]);
      bus.fire(
        const ContentDeleteEvent(
          ContentKind.story,
          's1',
          ContentDeleteStage.deleted,
        ),
      );
      await flush();
      expect(cubit.state.items.map((p) => p.authorId), ['a']);
      await cubit.close();
    });
  });

  test('a change on the rail reloads it', () async {
    final cubit = build();
    await cubit.start();
    when(getRail.call).thenAnswer((_) async => [person('a'), person('b')]);
    railChanges.add(null);
    await flush();
    expect(cubit.state.items, hasLength(2));
    await cubit.close();
  });

  test('a change that comes while loading is loaded after it, once', () async {
    final first = Completer<List<StoryRailItemEntity>>();
    when(getRail.call).thenAnswer((_) => first.future);
    final cubit = build();
    final started = cubit.start();
    railChanges.add(null);
    railChanges.add(null);
    await flush();
    when(getRail.call).thenAnswer((_) async => [person('b')]);
    first.complete([person('a')]);
    await started;
    await flush();
    expect(cubit.state.items.single.authorId, 'b');
    verify(getRail.call).called(2);
    await cubit.close();
  });

  test('follows how posting goes and reloads once it is done', () async {
    final cubit = build();
    await cubit.start();
    uploadStatus.add(const StoryUploading(0.4));
    await flush();
    expect(cubit.state.upload, const StoryUploading(0.4));

    when(getRail.call).thenAnswer((_) async => [person('me', isMe: true)]);
    uploadStatus.add(const StoryUploadDone());
    await flush();
    expect(cubit.state.me?.authorId, 'me');
    verify(getRail.call).called(2);

    uploadStatus.add(const StoryUploadFailed(NetworkFailure()));
    await flush();
    expect(cubit.state.upload, const StoryUploadFailed(NetworkFailure()));
    await cubit.close();
  });

  test('retryUpload asks the story feature to send it again', () async {
    final cubit = build();
    await cubit.start();
    cubit.retryUpload();
    verify(retry.call).called(1);
    await cubit.close();
  });

  test('stops listening when closed', () async {
    final cubit = build();
    await cubit.start();
    await cubit.close();
    railChanges.add(null);
    uploadStatus.add(const StoryUploading(0.5));
    await flush();
    verify(getRail.call).called(1);
  });

  test('reloads when Home is refreshed', () async {
    final cubit = build();
    await cubit.start();
    when(getRail.call).thenAnswer((_) async => [person('a'), person('b')]);
    requests.add(null);
    await flush();
    expect(cubit.state.items, hasLength(2));
    await cubit.close();
  });
}
