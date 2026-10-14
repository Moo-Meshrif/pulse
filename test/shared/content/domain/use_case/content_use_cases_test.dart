import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/enums/report_reason.dart';
import 'package:pulse/shared/content/data/datasource/content_actions_datasource.dart';
import 'package:pulse/shared/content/data/datasource/media_files_datasource.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/data/enums/mute_scope.dart';
import 'package:pulse/shared/content/domain/use_case/remove_media_files_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/report_content_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/set_content_audience_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/set_mute_use_case.dart';

class _Actions extends Mock implements ContentActionsDatasource {}

class _Files extends Mock implements MediaFilesDatasource {}

void main() {
  late _Actions actions;

  setUpAll(() {
    registerFallbackValue(ContentKind.post);
    registerFallbackValue(ReportReason.spam);
    registerFallbackValue(ContentAudience.public);
    registerFallbackValue(MuteScope.posts);
  });

  setUp(() => actions = _Actions());

  test('ReportContentUseCase passes the kind, reason and note on', () async {
    when(() => actions.report(any(), any(), any(), note: any(named: 'note')))
        .thenAnswer((_) async {});

    await ReportContentUseCase(actions)(
      ContentKind.short,
      'p1',
      ReportReason.spam,
      note: 'n',
    );

    verify(
      () =>
          actions.report(ContentKind.short, 'p1', ReportReason.spam, note: 'n'),
    ).called(1);
  });

  test('SetContentAudienceUseCase passes the audience on', () async {
    when(() => actions.setAudience(any(), any(), any()))
        .thenAnswer((_) async {});

    await SetContentAudienceUseCase(actions)(
      ContentKind.post,
      'p1',
      ContentAudience.onlyMe,
    );

    verify(
      () => actions.setAudience(ContentKind.post, 'p1', ContentAudience.onlyMe),
    ).called(1);
  });

  test('SetMuteUseCase mutes and unmutes for a scope', () async {
    when(
      () => actions.setMuted(
        any(),
        muted: any(named: 'muted'),
        scope: any(named: 'scope'),
      ),
    ).thenAnswer((_) async {});
    final useCase = SetMuteUseCase(actions);

    await useCase('u2', muted: true, scope: MuteScope.posts);
    await useCase('u2', muted: false, scope: MuteScope.posts);

    verifyInOrder([
      () => actions.setMuted('u2', muted: true, scope: MuteScope.posts),
      () => actions.setMuted('u2', muted: false, scope: MuteScope.posts),
    ]);
  });

  test('RemoveMediaFilesUseCase hands the paths to the files', () async {
    final files = _Files();
    when(() => files.remove(any())).thenAnswer((_) async {});

    await RemoveMediaFilesUseCase(files)(['a.jpg']);

    verify(() => files.remove(['a.jpg'])).called(1);
  });
}
