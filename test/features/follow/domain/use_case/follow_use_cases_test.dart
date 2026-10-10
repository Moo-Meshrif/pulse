import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/features/follow/data/datasource/follows_datasource.dart';
import 'package:pulse/features/follow/data/enums/follow_status.dart';
import 'package:pulse/features/follow/domain/use_case/respond_to_follow_request_use_case.dart';
import 'package:pulse/features/follow/domain/use_case/toggle_follow_use_case.dart';

class _MockFollows extends Mock implements FollowsDatasource {}

void main() {
  late _MockFollows follows;

  setUp(() => follows = _MockFollows());

  group('ToggleFollowUseCase', () {
    test('follow returns what the backend decided', () async {
      when(() => follows.follow('u2'))
          .thenAnswer((_) async => FollowStatus.pending);
      expect(
        await ToggleFollowUseCase(follows)('u2', follow: true),
        FollowStatus.pending,
      );
    });

    test('unfollow (or cancelling a request) returns none', () async {
      when(() => follows.unfollow('u2')).thenAnswer((_) async {});
      expect(
        await ToggleFollowUseCase(follows)('u2', follow: false),
        FollowStatus.none,
      );
      verify(() => follows.unfollow('u2')).called(1);
    });
  });

  group('RespondToFollowRequestUseCase', () {
    test('accepts, declines and accepts all', () async {
      when(() => follows.acceptRequest(any())).thenAnswer((_) async {});
      when(() => follows.declineRequest(any())).thenAnswer((_) async {});
      when(() => follows.acceptAllRequests()).thenAnswer((_) async {});
      final useCase = RespondToFollowRequestUseCase(follows);

      await useCase('u2', accept: true);
      await useCase('u3', accept: false);
      await useCase.acceptAll();

      verify(() => follows.acceptRequest('u2')).called(1);
      verify(() => follows.declineRequest('u3')).called(1);
      verify(() => follows.acceptAllRequests()).called(1);
    });
  });
}
