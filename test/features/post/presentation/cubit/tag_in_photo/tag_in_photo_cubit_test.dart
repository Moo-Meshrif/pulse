import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/post/presentation/cubit/tag_in_photo/tag_in_photo_cubit.dart';
import 'package:pulse/features/post/presentation/utils/tag_choice.dart';
import 'package:pulse/features/post/presentation/utils/tag_people_args.dart';
import 'package:pulse/features/post/presentation/utils/tag_photo.dart';

void main() {
  const omar = TagChoice(id: 'u1', username: 'omar');
  const laila = TagChoice(id: 'u2', username: 'laila');

  TagInPhotoCubit build({List<TagChoice> chosen = const [omar, laila]}) =>
      TagInPhotoCubit(
        TagPeopleArgs(
          chosen: chosen,
          photos: const [
            TagPhoto(position: 0, isVideo: false),
            TagPhoto(position: 1, isVideo: true),
            TagPhoto(position: 2, isVideo: false),
          ],
        ),
      );

  test('a video takes no spot: only the photos can be selected', () {
    final cubit = build();
    expect(cubit.state.photos.map((p) => p.position), [0, 2]);

    cubit.selectPhoto(1);
    expect(cubit.state.photo.position, 2);
    cubit.selectPhoto(5);
    expect(cubit.state.selected, 1);
  });

  test('a tap marks the spot, picking someone puts them there', () {
    final cubit = build()..tapPhoto(0.25, 0.75);
    expect(cubit.state.hasPending, isTrue);

    cubit.place('u1');

    final placed = cubit.state.chosen.first;
    expect(placed.mediaPosition, 0);
    expect(placed.x, 0.25);
    expect(placed.y, 0.75);
    expect(cubit.state.hasPending, isFalse);
    expect(cubit.state.labels.map((c) => c.id), ['u1']);
  });

  test('a tap outside the photo is kept inside it', () {
    final cubit = build()..tapPhoto(-0.2, 1.4);
    expect(cubit.state.pendingX, 0);
    expect(cubit.state.pendingY, 1);
  });

  test('a dismissed pick list takes the mark off', () {
    final cubit = build()
      ..tapPhoto(0.5, 0.5)
      ..cancelPending();
    expect(cubit.state.hasPending, isFalse);
    expect(cubit.state.chosen, [omar, laila]);
  });

  test('placing without a mark does nothing', () {
    final cubit = build()..place('u1');
    expect(cubit.state.chosen, [omar, laila]);
  });

  test('one spot per person: moving to another photo drops the first', () {
    final cubit = build()
      ..tapPhoto(0.1, 0.1)
      ..place('u1')
      ..selectPhoto(1)
      ..tapPhoto(0.9, 0.9)
      ..place('u1');

    final spots = cubit.state.chosen.where((c) => c.id == 'u1');
    expect(spots.single.mediaPosition, 2);
    expect(cubit.state.labels.single.id, 'u1');
    cubit.selectPhoto(0);
    expect(cubit.state.labels, isEmpty);
  });

  test('dragging a label moves it and never past the edge', () {
    final cubit = build()
      ..tapPhoto(0.5, 0.5)
      ..place('u1')
      ..move('u1', 0.6, 0.4);
    expect(cubit.state.chosen.first.x, 0.6);
    expect(cubit.state.chosen.first.y, 0.4);

    cubit.move('u1', 1.5, -0.3);
    expect(cubit.state.chosen.first.x, 1);
    expect(cubit.state.chosen.first.y, 0);
  });

  test('the × takes the spot off, the person stays tagged', () {
    final cubit = build()
      ..tapPhoto(0.5, 0.5)
      ..place('u1')
      ..removeSpot('u1');

    expect(cubit.state.chosen.length, 2);
    expect(cubit.state.chosen.first.hasSpot, isFalse);
    expect(cubit.state.withoutSpot.map((c) => c.id), ['u1', 'u2']);
  });

  test('counts the people on each photo, and knows what changed', () {
    final cubit = build();
    expect(cubit.hasChanges, isFalse);

    cubit
      ..tapPhoto(0.5, 0.5)
      ..place('u1')
      ..tapPhoto(0.2, 0.2)
      ..place('u2');

    expect(cubit.state.countOn(cubit.state.photos[0]), 2);
    expect(cubit.state.countOn(cubit.state.photos[1]), 0);
    expect(cubit.hasChanges, isTrue);
  });
}
