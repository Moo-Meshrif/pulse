import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/widgets/widgets.dart';

import '../../helpers/png_http_overrides.dart';
import '../../helpers/pump_app.dart';

ImageProvider providerOf(WidgetTester tester) =>
    tester.widget<Image>(find.byType(Image)).image;

void main() {
  final png = Uint8List.fromList(transparentPng);

  Future<void> show(WidgetTester tester, Widget image) => tester.pumpApp(
    Center(child: SizedBox(width: 40, height: 40, child: image)),
  );

  testWidgets('network: cached under the key given, not under the link', (
    tester,
  ) async {
    await show(
      tester,
      const AppImage.network(
        'https://x.test/a.jpg?token=1',
        cacheKey: 'u/a.jpg',
      ),
    );
    final provider = providerOf(tester) as CachedNetworkImageProvider;
    expect(provider.url, 'https://x.test/a.jpg?token=1');
    expect(provider.cacheKey, 'u/a.jpg');
  });

  testWidgets('file reads the file, memory the bytes, asset the bundle', (
    tester,
  ) async {
    await show(tester, const AppImage.file('/tmp/none.jpg'));
    expect(providerOf(tester), isA<FileImage>());

    await show(tester, AppImage.memory(png));
    expect(providerOf(tester), isA<MemoryImage>());

    await show(
      tester,
      const AppImage.asset('assets/images/onboarding/ar/onboarding_1.png'),
    );
    expect(providerOf(tester), isA<AssetImage>());
  });

  testWidgets('an .svg asset is drawn as a vector', (tester) async {
    await show(tester, const AppImage.asset('assets/icons/ic_close.svg'));
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('cacheWidth decodes no wider than that', (tester) async {
    await show(tester, AppImage.memory(png, cacheWidth: 80));
    final provider = providerOf(tester);
    expect(provider, isA<ResizeImage>());
    expect((provider as ResizeImage).width, 80);
  });

  testWidgets('a picture that cannot be loaded shows errorBuilder', (
    tester,
  ) async {
    await show(
      tester,
      AppImage.memory(
        Uint8List.fromList([1, 2, 3]),
        errorBuilder: (_) => const Text('broken'),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('broken'), findsOneWidget);
  });

  testWidgets('a picture that cannot be loaded shows nothing by default', (
    tester,
  ) async {
    await show(tester, AppImage.memory(Uint8List.fromList([1, 2, 3])));
    await tester.pump();
    await tester.pump();
    expect(find.byType(SizedBox), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('frameBuilder is the caller\'s, so it learns when the picture '
      'is ready', (tester) async {
    Widget mine(BuildContext c, Widget child, int? frame, bool sync) => child;
    await show(tester, AppImage.memory(png, frameBuilder: mine));
    expect(tester.widget<Image>(find.byType(Image)).frameBuilder, same(mine));
  });

  testWidgets('a placeholder shows until the first frame', (tester) async {
    await show(
      tester,
      AppImage.network(
        'https://x.test/slow.jpg',
        placeholder: const Text('wait'),
      ),
    );
    expect(find.text('wait'), findsOneWidget);
  });

  testWidgets('without a label the picture is skipped by a screen reader, with '
      'one it is read', (tester) async {
    await show(tester, AppImage.memory(png));
    expect(
      tester.widget<Image>(find.byType(Image)).excludeFromSemantics,
      isTrue,
    );

    await show(tester, AppImage.memory(png, semanticLabel: 'Profile photo'));
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.excludeFromSemantics, isFalse);
    expect(image.semanticLabel, 'Profile photo');
  });
}
