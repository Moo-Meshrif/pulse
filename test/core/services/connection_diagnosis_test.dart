import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/enums/connection_problem.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/services/connectivity_service.dart';

class MockConnectivity extends Mock implements Connectivity {}

class FakeReachService extends PlusConnectivityService {
  FakeReachService(super.connectivity, this.reach);

  final BackendReach reach;

  @override
  Future<BackendReach> probe() async => reach;
}

void main() {
  late MockConnectivity connectivity;

  setUp(() {
    connectivity = MockConnectivity();
    when(connectivity.checkConnectivity)
        .thenAnswer((_) async => [ConnectivityResult.wifi]);
  });

  test('no network is offline, without probing the backend', () async {
    when(connectivity.checkConnectivity)
        .thenAnswer((_) async => [ConnectivityResult.none]);
    final service = PlusConnectivityService(connectivity);

    expect(await service.isOffline(), isTrue);
    expect(
      await service.diagnose(const NetworkFailure()),
      ConnectionProblem.offline,
    );
  });

  test('a plugin failure does not count as offline', () async {
    when(connectivity.checkConnectivity).thenThrow(Exception('plugin'));
    expect(await PlusConnectivityService(connectivity).isOffline(), isFalse);
  });

  final cases = <(Failure, BackendReach, ConnectionProblem)>[
    (const NetworkFailure(), BackendReach.none, ConnectionProblem.noInternet),
    (const TimeoutFailure(), BackendReach.none, ConnectionProblem.noInternet),
    (const NetworkFailure(), BackendReach.slow, ConnectionProblem.weak),
    (const TimeoutFailure(), BackendReach.fast, ConnectionProblem.weak),
    (const NetworkFailure(), BackendReach.fast, ConnectionProblem.cantReach),
  ];
  for (final (failure, reach, problem) in cases) {
    test(
      '${failure.runtimeType} with a ${reach.name} backend is ${problem.name}',
      () async {
        final service = FakeReachService(connectivity, reach);
        expect(await service.diagnose(failure), problem);
      },
    );
  }
}
