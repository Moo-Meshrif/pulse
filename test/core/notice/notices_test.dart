import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/notice/notice.dart';
import 'package:pulse/core/notice/notices.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Notices.clear);

  test('a null message shows nothing', () {
    Notices.error(null);
    expect(Notices.current.value, isNull);
  });

  test('a notice of the same kind replaces the current one', () {
    Notices.success('One');
    Notices.success('Two');
    expect(Notices.current.value?.title, 'Two');
    Notices.dismiss(Notices.current.value!);
    expect(Notices.current.value, isNull);
  });

  test('another kind waits its turn, and at most two wait', () {
    Notices.success('Shown');
    Notices.info('A');
    Notices.error('B');
    Notices.info('C');
    expect(Notices.current.value?.title, 'Shown');
    Notices.dismiss(Notices.current.value!);
    expect(Notices.current.value?.title, 'B');
    Notices.dismiss(Notices.current.value!);
    expect(Notices.current.value?.title, 'C');
  });

  test('duration: 3 s info and success, 4 s error, 5 s with an action', () {
    expect(const Notice(NoticeKind.info, 'x').duration.inSeconds, 3);
    expect(const Notice(NoticeKind.error, 'x').duration.inSeconds, 4);
    final withAction = Notice(
      NoticeKind.error,
      'x',
      actionLabel: 'Retry',
      onAction: () {},
    );
    expect(withAction.duration.inSeconds, 5);
  });
}
