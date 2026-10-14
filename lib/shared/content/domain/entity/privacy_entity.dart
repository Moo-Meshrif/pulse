import '../../../../core/utils/equatable.dart';
import '../../data/enums/content_audience.dart';

/// What the post audience picker needs to know about the signed-in user.
class PrivacyEntity extends Equatable {
  final bool isPrivate;

  /// The audience a new post starts with: the saved default, never Public on a private account.
  final ContentAudience defaultVisibility;

  const PrivacyEntity({
    required this.isPrivate,
    required this.defaultVisibility,
  });

  @override
  List<Object?> get props => [isPrivate, defaultVisibility];
}
