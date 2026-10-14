import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/features/profile/data/datasource/profile_datasource.dart';
import 'package:pulse/features/profile/domain/use_case/get_current_user_id_use_case.dart';

class _Profiles extends Mock implements ProfileDatasource {}

void main() {
  test('answers the signed-in id, or null without a session', () {
    final profiles = _Profiles();
    final useCase = GetCurrentUserIdUseCase(profiles);
    when(() => profiles.currentUserId).thenReturn('u1');
    expect(useCase(), 'u1');
    when(() => profiles.currentUserId).thenReturn(null);
    expect(useCase(), isNull);
  });
}
