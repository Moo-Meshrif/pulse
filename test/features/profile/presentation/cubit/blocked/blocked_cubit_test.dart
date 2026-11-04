import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/profile/data/datasource/blocks_datasource.dart';
import 'package:pulse/features/profile/data/model/blocked_person_model.dart';
import 'package:pulse/features/profile/presentation/cubit/blocked/blocked_cubit.dart';
import 'package:pulse/features/profile/presentation/utils/enums/profile_status.dart';

class _MockBlocks extends Mock implements BlocksDatasource {}

void main() {
  const ann = BlockedPersonModel(id: 'a', username: 'ann');
  const bob = BlockedPersonModel(id: 'b', username: 'bob');
  late _MockBlocks blocks;
  late BlockedCubit cubit;

  setUp(() {
    blocks = _MockBlocks();
    cubit = BlockedCubit(blocks);
  });

  tearDown(() => cubit.close());

  test('load shows the people', () async {
    when(() => blocks.list()).thenAnswer((_) async => [ann, bob]);
    await cubit.load();
    expect(cubit.state.status, ProfileStatus.ready);
    expect(cubit.state.people, [ann, bob]);
    expect(cubit.state.hasMore, isFalse);
  });

  test('a failed load fails the page', () async {
    when(() => blocks.list()).thenThrow(const NetworkFailure());
    await cubit.load();
    expect(cubit.state.status, ProfileStatus.failed);
  });

  test('unblock removes the row and names who', () async {
    when(() => blocks.list()).thenAnswer((_) async => [ann, bob]);
    when(() => blocks.unblock('a')).thenAnswer((_) async {});
    await cubit.load();
    await cubit.unblock(ann);
    expect(cubit.state.people, [bob]);
    expect(cubit.state.unblockedUsername, 'ann');
    expect(cubit.state.unblocking, isEmpty);
  });

  test('a failed unblock keeps the row and reports it', () async {
    when(() => blocks.list()).thenAnswer((_) async => [ann]);
    when(() => blocks.unblock('a')).thenThrow(const NetworkFailure());
    await cubit.load();
    await cubit.unblock(ann);
    expect(cubit.state.people, [ann]);
    expect(cubit.state.failure, const NetworkFailure());
    expect(cubit.state.unblocking, isEmpty);
  });
}
