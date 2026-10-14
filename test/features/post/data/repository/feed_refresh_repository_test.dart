import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/post/data/repository/feed_refresh_repository.dart';

void main() {
  test('every listener hears each request', () async {
    final repository = FeedRefreshRepositoryImpl();
    var first = 0;
    var second = 0;
    repository.requests.listen((_) => first++);
    repository.requests.listen((_) => second++);
    repository
      ..request()
      ..request();
    await Future<void>.delayed(Duration.zero);
    expect((first, second), (2, 2));
  });

  test('a request nobody hears is dropped, not kept for later', () async {
    final repository = FeedRefreshRepositoryImpl()..request();
    var heard = 0;
    repository.requests.listen((_) => heard++);
    await Future<void>.delayed(Duration.zero);
    expect(heard, 0);
  });
}
