import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/utils/uuid_v4.dart';
import 'package:pulse/features/story/data/enums/story_media_type.dart';
import 'package:pulse/features/story/data/enums/story_overlay_type.dart';
import 'package:pulse/features/story/data/model/new_story_model.dart';
import 'package:pulse/features/story/data/model/story_model.dart';
import 'package:pulse/features/story/data/model/story_overlay_model.dart';

void main() {
  test('an overlay round-trips and keeps fractions as doubles', () {
    final json = {
      'type': 'location',
      'text': 'Cairo',
      'x': 1,
      'y': 0.25,
      'scale': 1.5,
      'rotation': -4,
      'color': '#FFFFFF',
    };
    final overlay = StoryOverlayModel.fromJson(json);
    expect(overlay.type, StoryOverlayType.location);
    expect(overlay.x, 1.0);
    expect(overlay.rotation, -4.0);
    expect(StoryOverlayModel.fromJson(overlay.toJson()), overlay);
  });

  test('a story row with missing or odd fields never throws', () {
    final story = StoryModel.fromJson({
      'id': 's1',
      'type': 'gif',
      'width': '1080',
      'overlays': [
        {'type': 'text', 'text': 'ok'},
        'not a map',
      ],
      'seen_by_me': 'yes',
    });
    expect(story.type, isNull);
    expect(story.width, 1080);
    expect(story.overlays, hasLength(1));
    expect(story.seenByMe, isNull);
    expect(story.durationMs, isNull);
  });

  test('withUrls keeps every other field', () {
    final story = StoryModel.fromJson({
      'id': 's1',
      'type': 'video',
      'duration_ms': 5000,
    });
    final signed = story.withUrls(mediaUrl: 'm', thumbUrl: 't');
    expect(signed.id, 's1');
    expect(signed.type, StoryMediaType.video);
    expect(signed.durationMs, 5000);
    expect(signed.mediaUrl, 'm');
    expect(signed.thumbUrl, 't');
  });

  test('media types know their upload name and MIME type', () {
    expect(StoryMediaType.image.extension, 'jpg');
    expect(StoryMediaType.image.contentType, 'image/jpeg');
    expect(StoryMediaType.video.extension, 'mp4');
    expect(StoryMediaType.fromWire('video'), StoryMediaType.video);
    expect(StoryMediaType.fromWire('x'), isNull);
  });

  test('a new story holds at most 20 stickers', () {
    expect(
      () => NewStoryModel(
        filePath: 'f',
        type: StoryMediaType.image,
        width: 1,
        height: 1,
        overlays: List.filled(21, const StoryOverlayModel()),
      ),
      throwsA(isA<AssertionError>()),
    );
  });

  test('a video needs a duration and a photo must not have one', () {
    expect(
      () => NewStoryModel(
        filePath: 'f',
        type: StoryMediaType.video,
        width: 1,
        height: 1,
      ),
      throwsA(isA<AssertionError>()),
    );
    expect(
      () => NewStoryModel(
        filePath: 'f',
        type: StoryMediaType.image,
        width: 1,
        height: 1,
        durationMs: 10,
      ),
      throwsA(isA<AssertionError>()),
    );
  });

  test('uuidV4 has the v4 shape and differs each time', () {
    final a = uuidV4();
    expect(
      a,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
    expect(uuidV4(), isNot(a));
  });
}
