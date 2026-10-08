import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/services/local_storage_service.dart';
import 'package:pulse/core/services/storage_keys.dart';
import 'package:pulse/features/profile/data/datasource/profile_local_datasource.dart';
import 'package:pulse/features/profile/data/enums/gender.dart';
import 'package:pulse/features/profile/data/enums/signup_step.dart';
import 'package:pulse/features/profile/data/model/profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPrefsStorageService storage;
  late ProfileLocalDatasource local;

  final profile = ProfileModel(
    id: 'u1',
    username: 'dip',
    fullName: 'Dip Roy',
    birthday: DateTime.utc(1999, 2, 3),
    gender: Gender.male,
    phone: '+201234567',
    city: 'Cairo',
    avatarUrl: 'https://x/y',
    signupStep: SignupStep.profile,
  );

  setUp(() async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    storage = SharedPrefsStorageService(await SharedPreferences.getInstance());
    local = ProfileLocalDatasource(storage);
  });

  test('nothing is saved at first', () {
    expect(local.read('u1'), isNull);
  });

  test('a saved profile reads back, without the private fields', () async {
    await local.write(profile);
    final saved = local.read('u1')!;
    expect(saved.username, 'dip');
    expect(saved.fullName, 'Dip Roy');
    expect(saved.signupStep, SignupStep.profile);
    expect(saved.avatarUrl, 'https://x/y');
    // Preferences are not encrypted: phone and birthday never reach them.
    expect(saved.phone, isNull);
    expect(saved.birthday, isNull);
  });

  test('each user has their own entry', () async {
    await local.write(profile);
    await local.write(profile.copyWith(username: 'other').toJsonOwnedBy('u2'));
    expect(local.read('u1')!.username, 'dip');
    expect(local.read('u2')!.username, 'other');
  });

  test('a profile without an id is not saved', () async {
    await local.write(const ProfileModel(username: 'x'));
    expect(storage.keys.where((k) => k.startsWith('profile_')), isEmpty);
  });

  test('clear forgets one user only', () async {
    await local.write(profile);
    await local.write(profile.copyWith().toJsonOwnedBy('u2'));
    await local.clear('u1');
    expect(local.read('u1'), isNull);
    expect(local.read('u2'), isNotNull);
  });

  test('the key is per user', () {
    expect(StorageKeys.profile('u1'), 'profile_u1');
  });

  test('corrupt saved data reads as nothing', () async {
    await storage.setValue<String>(StorageKeys.profile('u1'), 'not json');
    expect(local.read('u1'), isNull);
  });
}

extension on ProfileModel {
  ProfileModel toJsonOwnedBy(String id) =>
      ProfileModel.fromJson({...toJson(), 'id': id});
}
