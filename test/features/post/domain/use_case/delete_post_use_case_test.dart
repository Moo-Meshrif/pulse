import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/post/data/datasource/post_actions_datasource.dart';
import 'package:pulse/features/post/domain/use_case/delete_post_use_case.dart';
import 'package:pulse/shared/content/data/datasource/media_files_datasource.dart';

class _MockActions extends Mock implements PostActionsDatasource {}

class _MockFiles extends Mock implements MediaFilesDatasource {}

void main() {
  late _MockActions actions;
  late _MockFiles files;
  late DeletePostUseCase useCase;

  setUp(() {
    actions = _MockActions();
    files = _MockFiles();
    useCase = DeletePostUseCase(actions, files);
    when(() => files.listFolder('p1')).thenAnswer((_) async => ['u/p1/0.jpg']);
    when(() => files.remove(any())).thenAnswer((_) async {});
  });

  test('lists the files, deletes the row, then removes the files', () async {
    when(() => actions.deletePost('p1')).thenAnswer((_) async {});

    await useCase('p1');

    verifyInOrder([
      () => files.listFolder('p1'),
      () => actions.deletePost('p1'),
      () => files.remove(['u/p1/0.jpg']),
    ]);
  });

  test('a failed row delete keeps the files', () async {
    when(() => actions.deletePost('p1')).thenThrow(const NetworkFailure());

    await expectLater(useCase('p1'), throwsA(const NetworkFailure()));

    verifyNever(() => files.remove(any()));
  });
}
