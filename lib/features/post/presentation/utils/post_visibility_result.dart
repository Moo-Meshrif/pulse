import '../../../../core/utils/equatable.dart';
import '../../../../shared/content/data/enums/content_audience.dart';

/// What the picker hands back when the person confirms: the audience, and when it is the first time they
/// post to Close friends or Only me, which audience's notice to show and how many people it reaches.
class PostVisibilityResult extends Equatable {
  final ContentAudience audience;
  final ContentAudience? firstUseNotice;
  final int reach;

  /// "Use for future posts" was on: the audience is now the account's default.
  final bool savedAsDefault;

  const PostVisibilityResult({
    required this.audience,
    this.savedAsDefault = false,
    this.firstUseNotice,
    this.reach = 0,
  });

  @override
  List<Object?> get props => [audience, firstUseNotice, reach, savedAsDefault];
}
