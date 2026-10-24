import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/services/storage/app_folders.dart';
import 'package:pulse/core/services/storage/backup_exclusion.dart';
import 'package:pulse/core/services/storage/local_storage.dart';
import 'package:pulse/core/services/storage/storage_keys.dart';
import 'package:pulse/features/post/data/datasource/post_draft_datasource.dart';
import 'package:pulse/features/post/data/model/post_draft_media_model.dart';
import 'package:pulse/features/post/data/model/post_draft_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _Client extends Mock implements SupabaseClient {}

class _Auth extends Mock implements GoTrueClient {}

class _User extends Mock implements User {}

class _Backup extends Mock implements BackupExclusionService {}

void main() {
  late Directory support;
  late Directory temporary;
  late Directory elsewhere;
  late _Auth auth;
  late _Backup backup;
  late SharedPreferences prefs;
  late LocalPostDraftDatasource drafts;

  void signIn(String? uid) {
    if (uid == null) {
      when(() => auth.currentUser).thenReturn(null);
      return;
    }
    final user = _User();
    when(() => user.id).thenReturn(uid);
    when(() => auth.currentUser).thenReturn(user);
  }

  File fileIn(Directory folder, String name) =>
      File('${folder.path}/$name')..writeAsStringSync('bytes of $name');

  setUp(() async {
    final root = await Directory.systemTemp.createTemp('post_draft_test');
    support = await Directory('${root.path}/support').create();
    temporary = await Directory('${root.path}/tmp').create();
    elsewhere = await Directory('${root.path}/gallery').create();
    addTearDown(() => root.delete(recursive: true));

    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    auth = _Auth();
    final client = _Client();
    when(() => client.auth).thenReturn(auth);
    backup = _Backup();
    when(() => backup.exclude(any())).thenAnswer((_) async {});
    signIn('u1');
    drafts = LocalPostDraftDatasource(
      SharedPrefsStorageService(prefs),
      AppFolders(
        support: support.path,
        temporary: [temporary.path],
        cache: temporary.path,
      ),
      backup,
      client,
    );
  });

  PostDraftModel draftWith(List<PostDraftMediaModel> media) => PostDraftModel(
    id: 'd1',
    caption: 'hello',
    visibility: 'followers',
    media: media,
  );

  group('keep', () {
    test('moves the app\'s own temporary copy into the draft folder', () async {
      final picked = fileIn(temporary, 'pick.JPG');
      final kept = await drafts.keep('d1', picked.path);

      expect(kept, startsWith('${support.path}/post_drafts/u1/d1/'));
      expect(kept, endsWith('.jpg'));
      expect(File(kept).readAsStringSync(), 'bytes of pick.JPG');
      expect(picked.existsSync(), isFalse);
    });

    test('copies any other file and leaves it where it was', () async {
      final original = fileIn(elsewhere, 'photo.jpg');
      final kept = await drafts.keep('d1', original.path);

      expect(File(kept).existsSync(), isTrue);
      expect(original.existsSync(), isTrue);
    });

    test('leaves the drafts folder out of backups, once', () async {
      await drafts.keep('d1', fileIn(temporary, 'a.jpg').path);
      await drafts.keep('d1', fileIn(temporary, 'b.jpg').path);
      verify(() => backup.exclude('${support.path}/post_drafts')).called(1);
    });
  });

  group('save and read', () {
    test('everything comes back, with full paths', () async {
      final photo = await drafts.keep('d1', fileIn(temporary, 'a.jpg').path);
      final video = await drafts.keep('d1', fileIn(temporary, 'v.mp4').path);
      final frame = await drafts.keep('d1', fileIn(temporary, 'v.jpg').path);
      await drafts.save(
        draftWith([
          PostDraftMediaModel(path: photo, isVideo: false, width: 4, height: 3),
          PostDraftMediaModel(path: video, isVideo: true, poster: frame),
        ]),
      );

      final read = drafts.read()!;
      expect(read.id, 'd1');
      expect(read.caption, 'hello');
      expect(read.visibility, 'followers');
      expect(read.media!.map((m) => m.path), [photo, video]);
      expect(read.media!.first.width, 4);
      expect(read.media!.last.poster, frame);
    });

    test(
      'only file names are stored, so a moved app folder still works',
      () async {
        final photo = await drafts.keep('d1', fileIn(temporary, 'a.jpg').path);
        await drafts.save(draftWith([PostDraftMediaModel(path: photo)]));
        final stored = prefs.getString(StorageKeys.postDraft('u1'))!;
        expect(stored, isNot(contains(support.path)));
      },
    );

    test('a file that is gone is left out; a missing frame alone', () async {
      final photo = await drafts.keep('d1', fileIn(temporary, 'a.jpg').path);
      final video = await drafts.keep('d1', fileIn(temporary, 'v.mp4').path);
      final frame = await drafts.keep('d1', fileIn(temporary, 'v.jpg').path);
      await drafts.save(
        draftWith([
          PostDraftMediaModel(path: photo),
          PostDraftMediaModel(path: video, isVideo: true, poster: frame),
        ]),
      );
      File(photo).deleteSync();
      File(frame).deleteSync();

      final media = drafts.read()!.media!;
      expect(media.map((m) => m.path), [video]);
      expect(media.single.poster, isNull);
    });

    test('each user has their own draft', () async {
      await drafts.save(draftWith([]));
      signIn('u2');
      expect(drafts.read(), isNull);
      signIn('u1');
      expect(drafts.read()!.caption, 'hello');
    });

    test('no one signed in: nothing is read or saved', () async {
      signIn(null);
      await drafts.save(draftWith([]));
      expect(drafts.read(), isNull);
      expect(prefs.getKeys(), isEmpty);
    });

    test('an unreadable or older draft reads as none', () async {
      await prefs.setString(StorageKeys.postDraft('u1'), '{not json');
      expect(drafts.read(), isNull);
      await prefs.setString(StorageKeys.postDraft('u1'), '{"v":0,"id":"d1"}');
      expect(drafts.read(), isNull);
    });
  });

  group('forget and delete', () {
    test('forget removes the record and keeps the files', () async {
      final photo = await drafts.keep('d1', fileIn(temporary, 'a.jpg').path);
      await drafts.save(draftWith([PostDraftMediaModel(path: photo)]));
      await drafts.forget();
      expect(drafts.read(), isNull);
      expect(File(photo).existsSync(), isTrue);
    });

    test('deleteFiles removes the draft folder; twice is fine', () async {
      final photo = await drafts.keep('d1', fileIn(temporary, 'a.jpg').path);
      await drafts.deleteFiles('d1');
      await drafts.deleteFiles('d1');
      expect(File(photo).parent.existsSync(), isFalse);
    });

    test('deleteFile touches nothing outside the drafts folder', () async {
      final outside = fileIn(elsewhere, 'photo.jpg');
      await drafts.deleteFile(outside.path);
      expect(outside.existsSync(), isTrue);

      final kept = await drafts.keep('d1', fileIn(temporary, 'a.jpg').path);
      await drafts.deleteFile(kept);
      expect(File(kept).existsSync(), isFalse);
    });
  });

  group('shared posts', () {
    PostDraftModel sharedWith(String id, String file) => PostDraftModel(
      id: id,
      caption: 'shared $id',
      media: [PostDraftMediaModel(id: 'm1', path: file, isVideo: false)],
    );

    test('are kept by id, oldest first, with full paths', () async {
      final kept = await drafts.keep('p1', fileIn(temporary, 'a.jpg').path);
      await drafts.saveShared(sharedWith('p1', kept));
      await drafts.saveShared(sharedWith('p2', '/gone/b.jpg'));
      await drafts.saveShared(sharedWith('p1', kept)); // replaced, not added

      final shared = drafts.readShared()!;
      expect(shared.map((post) => post.id), ['p2', 'p1']);
      expect(shared.last.media!.single.path, kept);
      // A file that is gone stays: the server may have it.
      expect(
        shared.first.media!.single.path,
        '${support.path}/post_drafts/u1/p2/b.jpg',
      );

      await drafts.forgetShared('p2');
      expect(drafts.readShared()!.map((post) => post.id), ['p1']);
      await drafts.forgetShared('p1');
      expect(drafts.readShared(), isEmpty);
    });

    test('each user has their own; none signed in reads none', () async {
      await drafts.saveShared(sharedWith('p1', '/x/a.jpg'));
      signIn('u2');
      expect(drafts.readShared(), isEmpty);
      signIn(null);
      expect(drafts.readShared(), isEmpty);
      signIn('u1');
      expect(drafts.readShared(), hasLength(1));
    });

    test('a list that cannot be read is null, not empty', () async {
      await prefs.setString(StorageKeys.postShared('u1'), '[{"v": 99}]');
      expect(drafts.readShared(), isNull);
      await prefs.setString(StorageKeys.postShared('u1'), 'not json');
      expect(drafts.readShared(), isNull);
    });

    test('deleteFoldersExcept keeps the given folders only', () async {
      await drafts.keep('d1', fileIn(temporary, 'a.jpg').path);
      await drafts.keep('p1', fileIn(temporary, 'b.jpg').path);
      await drafts.keep('old', fileIn(temporary, 'c.jpg').path);
      final root = '${support.path}/post_drafts/u1';

      await drafts.deleteFoldersExcept({'d1', 'p1'});

      expect(Directory('$root/d1').existsSync(), isTrue);
      expect(Directory('$root/p1').existsSync(), isTrue);
      expect(Directory('$root/old').existsSync(), isFalse);
    });
  });
}
