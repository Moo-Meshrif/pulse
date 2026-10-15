import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/enums/permission_access.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/services/connectivity_service.dart';
import 'package:pulse/core/services/location_service.dart';
import 'package:pulse/core/utils/location_choice.dart';
import 'package:pulse/features/places/data/datasource/location_primer_datasource.dart';
import 'package:pulse/features/places/data/enums/place_kind.dart';
import 'package:pulse/features/places/data/repository/places_repository.dart';
import 'package:pulse/features/places/domain/entity/place_entity.dart';
import 'package:pulse/features/places/presentation/cubit/add_location_cubit.dart';
import 'package:pulse/features/places/presentation/utils/enums/location_search_status.dart';

class _Places extends Mock implements PlacesRepository {}

class _Location extends Mock implements LocationService {}

class _Connectivity extends Mock implements ConnectivityService {}

class _Primer extends Mock implements LocationPrimerDatasource {}

const _here = DevicePosition(latitude: 30.06, longitude: 31.22);
const _zamalek = PlaceEntity(
  name: 'Zamalek',
  subtitle: 'Cairo',
  kind: PlaceKind.neighborhood,
);
const _cafe = PlaceEntity(name: 'Pure Cafe', subtitle: 'Zamalek, Cairo');
const _karnak = PlaceEntity(name: 'Karnak Temple', subtitle: 'Luxor');

void main() {
  late _Places places;
  late _Location location;
  late _Connectivity connectivity;
  late _Primer primer;
  late StreamController<void> hints;
  late List<PlaceEntity> recent;

  setUpAll(() {
    registerFallbackValue(_here);
    registerFallbackValue(_cafe);
  });

  setUp(() {
    places = _Places();
    location = _Location();
    connectivity = _Connectivity();
    primer = _Primer();
    hints = StreamController<void>.broadcast();
    recent = [];
    when(() => places.recent()).thenAnswer((_) => recent);
    when(() => places.nearby(any(), languageCode: any(named: 'languageCode')))
        .thenAnswer((_) async => [_cafe]);
    when(
      () =>
          places.currentPlace(any(), languageCode: any(named: 'languageCode')),
    ).thenAnswer((_) async => _zamalek);
    when(() => places.saveRecent(any())).thenAnswer((_) async {});
    when(
      () => places.search(
        any(),
        near: any(named: 'near'),
        languageCode: any(named: 'languageCode'),
      ),
    ).thenAnswer((_) async => [_karnak]);
    when(() => location.permission())
        .thenAnswer((_) async => PermissionAccess.granted);
    when(() => location.currentPosition()).thenAnswer((_) async => _here);
    when(() => location.request()).thenAnswer((_) async {});
    when(() => location.openSettings()).thenAnswer((_) async => true);
    when(() => connectivity.isOffline()).thenAnswer((_) async => false);
    when(() => connectivity.connectionHints).thenAnswer((_) => hints.stream);
    when(() => primer.isDismissed).thenReturn(false);
    when(() => primer.markDismissed()).thenAnswer((_) async {});
  });

  tearDown(() => hints.close());

  AddLocationCubit build({String? current}) =>
      AddLocationCubit(places, location, connectivity, primer, current);

  group('the permission', () {
    test('granted loads the current place and nearby places', () async {
      final cubit = build();
      await cubit.start('en');

      expect(cubit.state.showPrimer, isFalse);
      expect(cubit.state.currentPlace, _zamalek);
      expect(cubit.state.nearby, [_cafe]);
      expect(cubit.state.shouldAutofocusSearch, isFalse);
    });

    test(
      'not asked yet shows the primer first, with the search focused',
      () async {
        when(() => location.permission())
            .thenAnswer((_) async => PermissionAccess.denied);
        final cubit = build();
        await cubit.start('en');

        expect(cubit.state.showPrimer, isTrue);
        expect(cubit.state.shouldAutofocusSearch, isTrue);
        verifyNever(() => location.currentPosition());
      },
    );

    test('Allow asks the system, then shows nearby', () async {
      var access = PermissionAccess.denied;
      when(() => location.permission()).thenAnswer((_) async => access);
      when(() => location.request()).thenAnswer((_) async {
        access = PermissionAccess.granted;
      });
      final cubit = build();
      await cubit.start('en');
      await cubit.allowLocation();

      verify(() => location.request()).called(1);
      expect(cubit.state.showPrimer, isFalse);
      expect(cubit.state.nearby, [_cafe]);
    });

    test('Allow and then refusing leaves search and recent only', () async {
      when(() => location.permission())
          .thenAnswer((_) async => PermissionAccess.denied);
      final cubit = build();
      await cubit.start('en');
      await cubit.allowLocation();

      expect(cubit.state.nearby, isEmpty);
      expect(cubit.state.showPrimer, isTrue);
    });

    test('Not now hides the primer and remembers it', () async {
      when(() => location.permission())
          .thenAnswer((_) async => PermissionAccess.denied);
      final cubit = build();
      await cubit.start('en');
      await cubit.notNow();

      expect(cubit.state.showPrimer, isFalse);
      verify(() => primer.markDismissed()).called(1);
    });

    test('a primer already dismissed does not come back', () async {
      when(() => location.permission())
          .thenAnswer((_) async => PermissionAccess.denied);
      when(() => primer.isDismissed).thenReturn(true);
      final cubit = build();
      await cubit.start('en');
      expect(cubit.state.showPrimer, isFalse);
    });

    test(
      'blocked: the button opens Settings, and coming back loads nearby',
      () async {
        var access = PermissionAccess.blocked;
        when(() => location.permission()).thenAnswer((_) async => access);
        final cubit = build();
        await cubit.start('en');
        expect(cubit.state.showPrimer, isTrue);

        await cubit.allowLocation();
        verify(() => location.openSettings()).called(1);
        verifyNever(() => location.request());

        access = PermissionAccess.granted;
        await cubit.recheckAccess();
        expect(cubit.state.showPrimer, isFalse);
        expect(cubit.state.nearby, [_cafe]);
      },
    );

    test('no fix leaves the screen without nearby places', () async {
      when(() => location.currentPosition()).thenAnswer((_) async => null);
      final cubit = build();
      await cubit.start('en');
      expect(cubit.state.nearby, isEmpty);
      expect(cubit.state.isLoadingNearby, isFalse);
    });
  });

  group('search', () {
    test('waits 300 ms and asks once for the last text', () {
      fakeAsync((async) {
        final cubit = build();
        cubit.start('ar');
        async.flushMicrotasks();

        cubit.queryChanged('ka');
        async.elapse(const Duration(milliseconds: 200));
        cubit.queryChanged('kar');
        async.elapse(const Duration(milliseconds: 299));
        verifyNever(
          () => places.search(
            any(),
            near: any(named: 'near'),
            languageCode: any(named: 'languageCode'),
          ),
        );

        async.elapse(const Duration(milliseconds: 1));
        async.flushMicrotasks();
        verify(() => places.search('kar', near: _here, languageCode: 'ar'))
            .called(1);
        expect(cubit.state.results, [_karnak]);
        expect(cubit.state.searchStatus, LocationSearchStatus.ready);
      });
    });

    test('one character does not search and clears older results', () {
      fakeAsync((async) {
        final cubit = build();
        cubit.start('en');
        async.flushMicrotasks();
        cubit.queryChanged('ka');
        async.elapse(const Duration(milliseconds: 300));
        async.flushMicrotasks();
        expect(cubit.state.results, isNotEmpty);

        cubit.queryChanged('k');
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(cubit.state.results, isEmpty);
        expect(cubit.state.searchStatus, LocationSearchStatus.idle);
      });
    });

    test('an older answer that arrives late is ignored', () {
      fakeAsync((async) {
        final slow = Completer<List<PlaceEntity>>();
        when(
          () => places.search(
            'ka',
            near: any(named: 'near'),
            languageCode: any(named: 'languageCode'),
          ),
        ).thenAnswer((_) => slow.future);
        final cubit = build();
        cubit.start('en');
        async.flushMicrotasks();

        cubit.queryChanged('ka');
        async.elapse(const Duration(milliseconds: 300));
        cubit.queryChanged('kar');
        async.elapse(const Duration(milliseconds: 300));
        async.flushMicrotasks();
        expect(cubit.state.results, [_karnak]);

        slow.complete(const [_cafe]);
        async.flushMicrotasks();
        expect(cubit.state.results, [_karnak]);
      });
    });

    test('a failed search says so; a connection failure says offline', () {
      fakeAsync((async) {
        when(
          () => places.search(
            any(),
            near: any(named: 'near'),
            languageCode: any(named: 'languageCode'),
          ),
        ).thenThrow(const ServerFailure());
        final cubit = build();
        cubit.start('en');
        async.flushMicrotasks();
        cubit.queryChanged('ka');
        async.elapse(const Duration(milliseconds: 300));
        async.flushMicrotasks();
        expect(cubit.state.searchStatus, LocationSearchStatus.failed);
        expect(cubit.state.isOffline, isFalse);

        when(
          () => places.search(
            any(),
            near: any(named: 'near'),
            languageCode: any(named: 'languageCode'),
          ),
        ).thenThrow(const NetworkFailure());
        cubit.queryChanged('kar');
        async.elapse(const Duration(milliseconds: 300));
        async.flushMicrotasks();
        expect(cubit.state.isOffline, isTrue);
      });
    });
  });

  group('offline', () {
    test('search does not run, and recent places are still there', () {
      fakeAsync((async) {
        recent = [_zamalek];
        when(() => connectivity.isOffline()).thenAnswer((_) async => true);
        when(() => location.permission())
            .thenAnswer((_) async => PermissionAccess.denied);
        when(() => primer.isDismissed).thenReturn(true);
        final cubit = build();
        cubit.start('en');
        async.flushMicrotasks();

        cubit.queryChanged('kar');
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(cubit.state.isOffline, isTrue);
        expect(cubit.state.recent, [_zamalek]);
        verifyNever(
          () => places.search(
            any(),
            near: any(named: 'near'),
            languageCode: any(named: 'languageCode'),
          ),
        );
      });
    });

    test('coming back online turns search on and loads nearby', () async {
      var offline = true;
      when(() => connectivity.isOffline()).thenAnswer((_) async => offline);
      final cubit = build();
      await cubit.start('en');
      expect(cubit.state.isOffline, isTrue);
      expect(cubit.state.nearby, isNotEmpty);

      offline = false;
      hints.add(null);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.isOffline, isFalse);
    });
  });

  group('choosing', () {
    test('a place goes first in recent and its name goes back', () async {
      final cubit = build();
      await cubit.start('en');
      await cubit.select(_cafe);

      verify(() => places.saveRecent(_cafe)).called(1);
      expect(cubit.state.result, const LocationChoice('Pure Cafe, Zamalek'));
    });

    test('a recent that cannot be saved still goes back', () async {
      when(() => places.saveRecent(any())).thenThrow(const UnexpectedFailure());
      final cubit = build();
      await cubit.start('en');
      await cubit.select(_zamalek);
      expect(cubit.state.result, const LocationChoice('Zamalek, Cairo'));
    });

    test('Remove goes back with no place', () async {
      final cubit = build(current: 'Zamalek, Cairo');
      await cubit.start('en');
      cubit.remove();
      expect(cubit.state.result, const LocationChoice(null));
    });
  });
}
