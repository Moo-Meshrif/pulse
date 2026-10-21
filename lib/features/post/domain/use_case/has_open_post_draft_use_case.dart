import 'package:injectable/injectable.dart';

import '../../data/repository/post_draft_repository.dart';

/// At start: whether the signed-in user's New post draft was left open, that is the app was closed while
/// they were writing it. Home then opens New post with it again.
@injectable
class HasOpenPostDraftUseCase {
  HasOpenPostDraftUseCase(this._draft);

  final PostDraftRepository _draft;

  bool call() => _draft.hasOpenDraft;
}
