import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/features/activity/data/datasource/activity_datasource.dart';
import 'package:pulse/features/activity/data/model/unread_activity_model.dart';
import 'package:pulse/features/activity/domain/use_case/get_unread_activity_count_use_case.dart';

class _Activity extends Mock implements ActivityDatasource {}

void main() {
  late _Activity activity;
  late GetUnreadActivityCountUseCase useCase;

  setUp(() {
    activity = _Activity();
    useCase = GetUnreadActivityCountUseCase(activity);
  });

  test('adds unread notifications and follow requests', () async {
    when(activity.getUnreadCount).thenAnswer(
      (_) async => const UnreadActivityModel(activity: 3, followRequests: 2),
    );
    expect(await useCase(), 5);
  });

  test('missing numbers count as zero', () async {
    when(activity.getUnreadCount)
        .thenAnswer((_) async => const UnreadActivityModel());
    expect(await useCase(), 0);
  });
}
