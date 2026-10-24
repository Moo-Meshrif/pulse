import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/services/storage/local_storage.dart';
import 'package:pulse/features/post/data/datasource/visibility_notice_datasource.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late VisibilityNoticeDatasource notices;

  setUp(() async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    notices = VisibilityNoticeDatasource(
      SharedPrefsStorageService(await SharedPreferences.getInstance()),
    );
  });

  test('nothing is seen at first', () {
    for (final visibility in ContentAudience.values) {
      expect(notices.isSeen(visibility), isFalse);
    }
  });

  test('each audience is remembered on its own', () async {
    await notices.markSeen(ContentAudience.closeFriends);

    expect(notices.isSeen(ContentAudience.closeFriends), isTrue);
    expect(notices.isSeen(ContentAudience.onlyMe), isFalse);
  });
}
