import '../../../../core/utils/equatable.dart';

/// Who last signed in on this device, from the saved copy of their profile: enough for Sign in to name
/// the account after its session ended. Never holds a phone or birthday.
class LastAccountEntity extends Equatable {
  final String id;
  final String username;
  final String? fullName;
  final String? avatarUrl;

  const LastAccountEntity({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, username, fullName, avatarUrl];
}
