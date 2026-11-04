import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/events/event_bus.dart';
import 'package:pulse/features/profile/data/repository/profile_repository.dart';
import 'package:pulse/features/profile/domain/entity/profile_entity.dart';
import 'package:pulse/features/profile/domain/event/profile_updated.dart';
import 'package:pulse/features/profile/presentation/cubit/own_author/own_author_cubit.dart';
import 'package:pulse/features/profile/presentation/cubit/own_author/own_author_state.dart';

class _MockProfiles extends Mock implements ProfileRepository {}

void main() {
  late _MockProfiles profiles;
  late EventBus bus;
  late OwnAuthorCubit cubit;

  const old = ProfileEntity(id: 'me', username: 'sam', fullName: 'Sam');
  const fresh = ProfileEntity(
    id: 'me',
    username: 'sam',
    fullName: 'Samir',
    avatarUrl: 'https://x/a.png',
  );

  setUp(() {
    profiles = _MockProfiles();
    bus = EventBus();
    cubit = OwnAuthorCubit(profiles, bus);
  });

  tearDown(() => cubit.close());

  test('start shows the saved copy without a request', () async {
    when(() => profiles.savedProfile()).thenReturn(old);
    await cubit.start();
    expect(cubit.state.fullName, 'Sam');
    verifyNever(() => profiles.getProfile());
  });

  test('with no saved copy it reads the server once', () async {
    when(() => profiles.savedProfile()).thenReturn(null);
    when(() => profiles.getProfile()).thenAnswer((_) async => old);
    await cubit.start();
    expect(cubit.state.id, 'me');
  });

  test('a failed server read leaves the state empty', () async {
    when(() => profiles.savedProfile()).thenReturn(null);
    when(() => profiles.getProfile()).thenThrow(const NetworkFailure());
    await cubit.start();
    expect(cubit.state, const OwnAuthorState());
  });

  test('a saved Personal info shows from the copy, offline too', () async {
    var saved = old;
    when(() => profiles.savedProfile()).thenAnswer((_) => saved);
    await cubit.start();
    saved = fresh;
    bus.fire(const ProfileUpdated());
    await pumpEventQueue();
    expect(cubit.state.fullName, 'Samir');
    expect(cubit.state.avatarUrl, 'https://x/a.png');
    verifyNever(() => profiles.getProfile());
  });

  test('a profile without a username leaves the state empty', () async {
    when(() => profiles.savedProfile())
        .thenReturn(const ProfileEntity(id: 'me'));
    when(() => profiles.getProfile())
        .thenAnswer((_) async => const ProfileEntity(id: 'me'));
    await cubit.start();
    expect(cubit.state, const OwnAuthorState());
  });
}
