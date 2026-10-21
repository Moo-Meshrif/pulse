import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/services/local_storage_service.dart';
import 'package:pulse/shared/content/data/datasource/content_discards_datasource.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/data/model/content_discard_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _Client extends Mock implements SupabaseClient {}

class _Auth extends Mock implements GoTrueClient {}

class _User extends Mock implements User {}

void main() {
  late _Auth auth;
  late LocalContentDiscardsDatasource discards;

  void signIn(String? uid) {
    if (uid == null) {
      when(() => auth.currentUser).thenReturn(null);
      return;
    }
    final user = _User();
    when(() => user.id).thenReturn(uid);
    when(() => auth.currentUser).thenReturn(user);
  }

  List<String?> ids() => [for (final item in discards.read()) item.id];

  setUp(() async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    auth = _Auth();
    final client = _Client();
    when(() => client.auth).thenReturn(auth);
    signIn('u1');
    discards = LocalContentDiscardsDatasource(
      SharedPrefsStorageService(prefs),
      client,
    );
  });

  test('keeps each discard once, in order, with its kind', () async {
    await discards.add(
      const ContentDiscardModel(id: 'p1', kind: ContentKind.post),
    );
    await discards.add(
      const ContentDiscardModel(id: 'p2', kind: ContentKind.story),
    );
    await discards.add(
      const ContentDiscardModel(id: 'p1', kind: ContentKind.post),
    );

    expect(ids(), ['p1', 'p2']);
    expect(discards.read().last.kind, ContentKind.story);

    await discards.remove('p1');
    expect(ids(), ['p2']);
  });

  test('each user has their own list', () async {
    await discards.add(
      const ContentDiscardModel(id: 'p1', kind: ContentKind.post),
    );
    signIn('u2');
    expect(discards.read(), isEmpty);
    signIn(null);
    expect(discards.read(), isEmpty);
    signIn('u1');
    expect(ids(), ['p1']);
  });
}
