import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/services/photo_picker_service.dart';
import 'package:pulse/features/profile/data/datasource/problem_report_datasource.dart';
import 'package:pulse/features/profile/data/enums/problem_category.dart';
import 'package:pulse/features/profile/presentation/cubit/report/report_cubit.dart';

class _Reports extends Mock implements ProblemReportDatasource {}

void main() {
  late _Reports datasource;
  late ReportCubit cubit;
  setUp(() {
    datasource = _Reports();
    cubit = ReportCubit(datasource);
  });
  tearDown(() => cubit.close());

  test('requires category and ten non-whitespace characters', () {
    cubit.messageChanged('123456789');
    expect(cubit.state.canSend, false);
    cubit.categoryChanged(ProblemCategory.feed);
    expect(cubit.state.canSend, false);
    cubit.messageChanged(' 1234567890 ');
    expect(cubit.state.canSend, true);
    cubit.messageChanged(' ' * 20);
    expect(cubit.state.canSend, false);
  });

  test('keeps at most three screenshots', () {
    final photos = List.generate(
      4,
      (_) => PickedPhoto(bytes: Uint8List(1), contentType: 'image/jpeg'),
    );
    cubit.addPhotos(photos);
    expect(cubit.state.photos.length, 3);
    cubit.removePhoto(1);
    expect(cubit.state.photos.length, 2);
  });

  test('failed send keeps the text and screenshots', () async {
    final photo = PickedPhoto(bytes: Uint8List(1), contentType: 'image/jpeg');
    cubit.categoryChanged(ProblemCategory.feed);
    cubit.messageChanged('The feed is broken');
    cubit.addPhotos([photo]);
    when(
      () => datasource.submit(
        category: any(named: 'category'),
        message: any(named: 'message'),
        photos: any(named: 'photos'),
        includeLogs: any(named: 'includeLogs'),
        onProgress: any(named: 'onProgress'),
      ),
    ).thenThrow(const NetworkFailure());
    await cubit.send();
    expect(cubit.state.message, 'The feed is broken');
    expect(cubit.state.photos, [photo]);
    expect(cubit.state.failure, const NetworkFailure());
    expect(cubit.state.canSend, true);
  });

  test('sends category and text successfully', () async {
    cubit.categoryChanged(ProblemCategory.signingIn);
    cubit.messageChanged('Cannot sign in');
    when(
      () => datasource.submit(
        category: any(named: 'category'),
        message: any(named: 'message'),
        photos: any(named: 'photos'),
        includeLogs: any(named: 'includeLogs'),
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((_) async {});
    await cubit.send();
    expect(cubit.state.sent, true);
    verify(
      () => datasource.submit(
        category: 'signing_in',
        message: 'Cannot sign in',
        photos: [],
        includeLogs: true,
        onProgress: any(named: 'onProgress'),
      ),
    ).called(1);
  });
}
