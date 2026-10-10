import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/enums/auth_failure_reason.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/guard.dart';
import '../../../../core/utils/json_mapper.dart';
import '../model/profile_model.dart';
import '../model/profile_update_model.dart';

/// The remote source of the signed-in user's profile, as an interface because the backend will change.
/// Every call throws a `Failure` on error.
abstract interface class ProfileDatasource {
  /// The signed-in user's id, or null without a session.
  String? get currentUserId;

  Future<ProfileModel> getProfile();

  /// Whether [username] matches the format and nobody else has it.
  Future<bool> isUsernameAvailable(String username);

  /// Writes only the fields that are set and returns the profile as the server now stores it.
  /// A taken username is `ConflictFailure`.
  Future<ProfileModel> updateProfile(ProfileUpdateModel update);

  /// Stores the picture and returns its public URL (not yet saved on the profile).
  Future<String> uploadAvatar(Uint8List bytes, {required String contentType});

  /// Deletes the stored picture and clears the profile's avatar.
  Future<void> removeAvatar();
}

/// [ProfileDatasource] as an adapter over Supabase: the `profiles` table, its `is_username_available`
/// function and the `avatars` bucket (docs/specs/auth/schema.sql).
@LazySingleton(as: ProfileDatasource)
final class SupabaseProfileDatasource implements ProfileDatasource {
  SupabaseProfileDatasource(this._client);

  static const _avatarsBucket = 'avatars';

  final SupabaseClient _client;

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  /// The signed-in user's id; no session is `AuthFailure(sessionExpired)`.
  String get _uid =>
      currentUserId ??
      (throw const AuthRejectedException(AuthFailureReason.sessionExpired));

  /// One file per user, replaced on every upload.
  String get _avatarPath => '$_uid/avatar';

  @override
  Future<ProfileModel> getProfile() => Guard.run(() async {
    final row = await _client.from('profiles').select().eq('id', _uid).single();
    return ProfileModel.fromJson(row);
  });

  @override
  Future<bool> isUsernameAvailable(String username) => Guard.run(() async {
    final available = await _client.rpc<dynamic>(
      'is_username_available',
      params: {'p_username': username},
    );
    return JsonMapper.boolean(available) ?? false;
  });

  @override
  Future<ProfileModel> updateProfile(ProfileUpdateModel update) =>
      Guard.run(() async {
        final row = await _client
            .from('profiles')
            .update(update.toJson())
            .eq('id', _uid)
            .select()
            .single();
        return ProfileModel.fromJson(row);
      });

  @override
  Future<String> uploadAvatar(Uint8List bytes, {required String contentType}) =>
      Guard.run(() async {
        final storage = _client.storage.from(_avatarsBucket);
        await storage.uploadBinary(
          _avatarPath,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: true),
        );
        // The path never changes, so a version in the query keeps image caches from showing the old picture.
        return '${storage.getPublicUrl(_avatarPath)}'
            '?v=${clock.now().millisecondsSinceEpoch}';
      });

  @override
  Future<void> removeAvatar() => Guard.run(() async {
    await _client.storage.from(_avatarsBucket).remove([_avatarPath]);
    await _client.from('profiles').update({'avatar_url': null}).eq('id', _uid);
  });
}
