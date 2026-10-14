import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/enums/permission_access.dart';
import 'package:pulse/core/services/connectivity_service.dart';
import 'package:pulse/core/services/location_service.dart';
import 'package:pulse/shared/places/data/datasource/location_primer_datasource.dart';
import 'package:pulse/shared/places/data/enums/place_kind.dart';
import 'package:pulse/shared/places/data/repository/places_repository.dart';
import 'package:pulse/shared/places/domain/entity/place_entity.dart';
import 'package:pulse/shared/places/presentation/cubit/add_location_cubit.dart';
import 'package:pulse/shared/places/presentation/screen/add_location_screen.dart';
import 'package:pulse/shared/places/presentation/utils/location_choice.dart';

import '../../../../helpers/pump_app.dart';

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
const _tower = PlaceEntity(
  name: 'Cairo Tower',
  subtitle: 'Zamalek, Cairo',
  distanceKm: 0.8,
);
const _alex = PlaceEntity(
  name: 'Alexandria',
  subtitle: 'Egypt',
  kind: PlaceKind.city,
);
const _karnak = PlaceEntity(name: 'Karnak Temple', subtitle: 'Luxor, Egypt');

void main() {
  late _Places places;
  late _Location location;
  late _Primer primer;
  late PermissionAccess access;
  late List<PlaceEntity> searchResults;
  Object? popped;

  setUpAll(() {
    registerFallbackValue(_here);
    registerFallbackValue(_tower);
  });

  setUp(() async {
    await getIt.reset();
    popped = null;
    access = PermissionAccess.granted;
    searchResults = [_karnak];
    places = _Places();
    location = _Location();
    primer = _Primer();
    final connectivity = _Connectivity();
    when(places.recent).thenReturn([_alex]);
    when(() => places.nearby(any(), languageCode: any(named: 'languageCode')))
        .thenAnswer((_) async => [_tower]);
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
    ).thenAnswer((_) async => searchResults);
    when(() => location.permission()).thenAnswer((_) async => access);
    when(() => location.currentPosition()).thenAnswer((_) async => _here);
    when(() => location.request()).thenAnswer((_) async {});
    when(() => connectivity.isOffline()).thenAnswer((_) async => false);
    when(() => connectivity.connectionHints)
        .thenAnswer((_) => const Stream.empty());
    when(() => primer.isDismissed).thenReturn(false);
    when(() => primer.markDismissed()).thenAnswer((_) async {});
    getIt.registerFactoryParam<AddLocationCubit, String?, dynamic>(
      (current, _) =>
          AddLocationCubit(places, location, connectivity, primer, current),
    );
  });

  tearDown(getIt.reset);

  Future<void> open(
    WidgetTester tester, {
    String? current,
    Locale locale = const Locale('en'),
    double textScale = 1,
    Size size = const Size(390, 844),

    /// False for the primer: its icon floats forever, so the page never settles.
    bool settle = true,
  }) async {
    setUpView(tester, textScale: textScale, size: size);
    await tester.pumpApp(
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async => popped = await Navigator.of(context).push(
              MaterialPageRoute<Object>(
                builder: (_) => AddLocationScreen(current: current),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
      locale: locale,
    );
    await tester.tap(find.text('open'));
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    }
  }

  testWidgets('shows where you are, nearby and recent places', (tester) async {
    await open(tester);

    expect(find.text(l10nEn.locationTitle), findsOneWidget);
    expect(find.text(l10nEn.locationUseCurrent), findsOneWidget);
    expect(find.text('Zamalek, Cairo'), findsOneWidget);
    expect(find.text(l10nEn.locationNearby.toUpperCase()), findsOneWidget);
    expect(find.text('Cairo Tower'), findsOneWidget);
    expect(find.text('Zamalek, Cairo · 0.8 km'), findsOneWidget);
    expect(find.text(l10nEn.locationRecent.toUpperCase()), findsOneWidget);
    expect(find.text('Alexandria'), findsOneWidget);
    expect(find.text('City · Egypt'), findsOneWidget);
    expect(find.text(l10nEn.locationRemove), findsNothing);
  });

  testWidgets('Remove shows only when the post has a location, and clears it', (
    tester,
  ) async {
    await open(tester, current: 'Alexandria, Egypt');
    await tester.tap(find.text(l10nEn.locationRemove));
    await tester.pumpAndSettle();
    expect(popped, const LocationChoice(null));
  });

  testWidgets('the place already on the post is marked selected', (
    tester,
  ) async {
    await open(tester, current: 'Cairo Tower, Zamalek');
    expect(
      find.bySemanticsLabel(RegExp('Cairo Tower.*${l10nEn.locationSelected}')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp('Alexandria.*${l10nEn.locationSelected}')),
      findsNothing,
    );
  });

  testWidgets('tapping a row goes back with its name', (tester) async {
    await open(tester);
    await tester.tap(find.text('Cairo Tower'));
    await tester.pumpAndSettle();
    expect(popped, const LocationChoice('Cairo Tower, Zamalek'));
    verify(() => places.saveRecent(_tower)).called(1);
  });

  testWidgets('typing shows results with the typed part in bold', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(find.byType(TextField), 'kar');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text(l10nEn.locationResults.toUpperCase()), findsOneWidget);
    final title = tester.widget<Text>(find.textContaining('nak Temple'));
    final spans = (title.textSpan! as TextSpan).children!.cast<TextSpan>();
    expect(spans.map((s) => s.text), ['', 'Kar', 'nak Temple']);
    expect(spans[1].style!.fontWeight, FontWeight.w700);
    expect(find.text('Cairo Tower'), findsNothing);
  });

  testWidgets('nothing found shows the empty panel', (tester) async {
    searchResults = [];
    await open(tester);
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.text(l10nEn.locationNoResults), findsOneWidget);
  });

  testWidgets('clearing the text brings the lists back', (tester) async {
    await open(tester);
    await tester.enterText(find.byType(TextField), 'kar');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel(l10nEn.locationClearSearch));
    await tester.pumpAndSettle();
    expect(find.text('Cairo Tower'), findsOneWidget);
  });

  testWidgets(
    'not asked yet shows the primer; Not now shows search and recent',
    (tester) async {
      access = PermissionAccess.denied;
      await open(tester, settle: false);
      expect(find.text(l10nEn.locationPrimerTitle), findsOneWidget);
      expect(find.text(l10nEn.locationAllow), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      await tester.tap(find.text(l10nEn.locationNotNow));
      await tester.pumpAndSettle();
      expect(find.text(l10nEn.locationPrimerTitle), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Alexandria'), findsOneWidget);
      expect(find.text('Cairo Tower'), findsNothing);
    },
  );

  testWidgets('blocked: the primer button reads Open settings', (tester) async {
    access = PermissionAccess.blocked;
    await open(tester, settle: false);
    expect(find.text(l10nEn.locationOpenSettings), findsOneWidget);
  });

  testWidgets('Arabic at 1.5x text does not overflow', (tester) async {
    await open(tester, locale: const Locale('ar'), textScale: 1.5);
    expect(find.text(l10nAr.locationTitle), findsOneWidget);
    expect(find.text(l10nAr.locationUseCurrent), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a 320 dp phone at 2.0x text, EN and AR, does not overflow', (
    tester,
  ) async {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      await tester.pumpWidget(const SizedBox());
      await open(
        tester,
        locale: locale,
        textScale: 2,
        size: const Size(320, 640),
      );
      expect(tester.takeException(), isNull, reason: locale.languageCode);
    }
  });
}
