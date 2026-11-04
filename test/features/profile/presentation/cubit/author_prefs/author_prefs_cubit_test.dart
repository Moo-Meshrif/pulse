import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/services/launch_service.dart';
import 'package:pulse/features/profile/data/datasource/author_prefs_datasource.dart';
import 'package:pulse/features/profile/presentation/cubit/author_prefs/author_prefs_cubit.dart';
import 'package:pulse/shared/content/data/enums/mute_scope.dart';
import 'package:pulse/shared/content/domain/use_case/set_mute_use_case.dart';

class _Prefs extends Mock implements AuthorPrefsDatasource {}

class _Mute extends Mock implements SetMuteUseCase {}

class _Launch extends Mock implements LaunchService {}

void main() {
  late _Prefs prefs;
  late _Mute mute;
  late AuthorPrefsCubit cubit;

  setUp(() {
    prefs = _Prefs();
    mute = _Mute();
    cubit = AuthorPrefsCubit(prefs, mute, _Launch(), 'target');
    when(() => prefs.load('target'))
        .thenAnswer((_) async => [false, false, false, false]);
  });
  tearDown(() => cubit.close());

  test('preference changes optimistically and rolls back on failure', () async {
    final pending = Completer<void>();
    when(() => prefs.set('target', enabled: true, closeFriend: true))
        .thenAnswer((_) => pending.future);
    await cubit.load();
    final action = cubit.change(0, true);
    expect(cubit.state.values![0], isTrue);
    expect(cubit.state.busy, isTrue);
    pending.completeError(const NetworkFailure());
    await action;
    expect(cubit.state.values![0], isFalse);
    expect(cubit.state.failure, isA<NetworkFailure>());
  });

  test('failed story mute restores the previous post mute', () async {
    when(() => mute('target', muted: true, scope: MuteScope.posts))
        .thenAnswer((_) async {});
    when(() => mute('target', muted: true, scope: MuteScope.stories))
        .thenThrow(const NetworkFailure());
    when(() => mute('target', muted: false, scope: MuteScope.posts))
        .thenAnswer((_) async {});
    await cubit.load();
    await cubit.change(2, true);
    expect(cubit.state.values, [false, false, false, false]);
    expect(cubit.state.failure, isA<NetworkFailure>());
    verify(() => mute('target', muted: false, scope: MuteScope.posts))
        .called(1);
  });
}
