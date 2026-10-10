import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/state/base_cubit.dart';

class _Cubit extends BaseCubit<String> {
  _Cubit() : super('start');

  Future<void> load(
    Future<int> Function() action, {
    String? loading,
    String? Function(int)? onSuccess,
    String? Function(Failure)? onFailure,
  }) => run(
    action,
    loading: loading,
    onSuccess: onSuccess ?? (n) => 'ok $n',
    onFailure: onFailure ?? (f) => 'failed ${f.runtimeType}',
  );
}

void main() {
  late _Cubit cubit;
  late List<String> emitted;

  setUp(() {
    cubit = _Cubit();
    emitted = [];
    cubit.stream.listen(emitted.add);
  });

  tearDown(() => cubit.close());

  test('emits the loading state first, then the success state', () async {
    await cubit.load(() async => 1, loading: 'loading');
    await Future<void>.delayed(Duration.zero);
    expect(emitted, ['loading', 'ok 1']);
  });

  test('a thrown Failure reaches onFailure', () async {
    await cubit.load(() async => throw const NetworkFailure());
    await Future<void>.delayed(Duration.zero);
    expect(emitted, ['failed NetworkFailure']);
  });

  test('any other error reaches onFailure as an UnexpectedFailure', () async {
    await cubit.load(() async => throw StateError('bug'));
    await Future<void>.delayed(Duration.zero);
    expect(emitted, ['failed UnexpectedFailure']);
  });

  test('a callback that returns null emits nothing', () async {
    await cubit.load(() async => 1, onSuccess: (_) => null);
    await cubit.load(
      () async => throw const TimeoutFailure(),
      onFailure: (_) => null,
    );
    await Future<void>.delayed(Duration.zero);
    expect(emitted, isEmpty);
  });

  test('finishing after the cubit closed does not throw', () async {
    final pending = cubit.load(() async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return 1;
    });
    await cubit.close();
    await pending;
  });
}
