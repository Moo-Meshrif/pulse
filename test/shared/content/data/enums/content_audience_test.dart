import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';

void main() {
  test('wire values match the database check', () {
    expect(ContentAudience.values.map((v) => v.wire), [
      'public',
      'followers',
      'close_friends',
      'only_me',
    ]);
  });

  test('fromWire finds each value and ignores unknown ones', () {
    for (final visibility in ContentAudience.values) {
      expect(ContentAudience.fromWire(visibility.wire), visibility);
    }
    expect(ContentAudience.fromWire('friends'), isNull);
    expect(ContentAudience.fromWire(null), isNull);
  });

  test('only Close friends and Only me have a first-use notice', () {
    expect(ContentAudience.values.where((v) => v.hasFirstUseNotice), [
      ContentAudience.closeFriends,
      ContentAudience.onlyMe,
    ]);
  });
}
