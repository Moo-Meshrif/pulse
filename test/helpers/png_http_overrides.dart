import 'dart:async';
import 'dart:io';

import 'package:mocktail/mocktail.dart';

/// A 1 x 1 transparent PNG.
const transparentPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

class _Client extends Mock implements HttpClient {}

class _Request extends Mock implements HttpClientRequest {}

class _Response extends Mock implements HttpClientResponse {}

class _Headers extends Mock implements HttpHeaders {}

/// Makes every `Image.network` in a test load [transparentPng] (flutter_test answers 400 otherwise, which
/// is the error path of the image).
class PngHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    // `any()` below needs it; without it `when` throws halfway and mocktail keeps a stub half-made, so
    // every later `when` in the test file fails with "Cannot call `when` within a stub response".
    registerFallbackValue(Uri());
    final client = _Client();
    final request = _Request();
    final response = _Response();
    when(() => client.getUrl(any())).thenAnswer((_) async => request);
    when(() => request.headers).thenReturn(_Headers());
    when(request.close).thenAnswer((_) async => response);
    when(() => response.statusCode).thenReturn(200);
    when(() => response.contentLength).thenReturn(transparentPng.length);
    when(() => response.compressionState)
        .thenReturn(HttpClientResponseCompressionState.notCompressed);
    when(
      () => response.listen(
        any(),
        onError: any(named: 'onError'),
        onDone: any(named: 'onDone'),
        cancelOnError: any(named: 'cancelOnError'),
      ),
    ).thenAnswer((invocation) {
      final onData =
          invocation.positionalArguments[0] as void Function(List<int>)?;
      final onDone = invocation.namedArguments[#onDone] as void Function()?;
      return Stream<List<int>>.fromIterable([transparentPng])
          .listen(onData, onDone: onDone);
    });
    return client;
  }
}
