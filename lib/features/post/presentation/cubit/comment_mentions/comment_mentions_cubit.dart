import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../../core/state/base_cubit.dart';
import '../../../domain/entity/mention_person_entity.dart';
import '../../../domain/use_case/get_mention_candidates_use_case.dart';
import '../../utils/comment_text.dart';

/// The people suggested while `@word` is typed in a comment: one request per pause, the newest answer
/// only. Offline or a failure shows no one. The state is the list to show.
@injectable
class CommentMentionsCubit extends BaseCubit<List<MentionPersonEntity>> {
  CommentMentionsCubit(this._candidates, @factoryParam this.postId)
    : super(const []);

  final GetMentionCandidatesUseCase _candidates;
  final String postId;

  Timer? _debounce;

  /// A newer query makes an older answer stale.
  int _request = 0;

  /// The letters typed after the `@`; null when no mention is being typed (hides the list).
  void queryChanged(String? query) {
    _debounce?.cancel();
    final request = ++_request;
    if (query == null || query.isEmpty) {
      if (state.isNotEmpty) emit(const []);
      return;
    }
    _debounce = Timer(CommentText.mentionDelay, () => _fetch(query, request));
  }

  Future<void> _fetch(String query, int request) => run(
    () => _candidates(postId, query),
    onSuccess: (people) => request == _request ? people : null,
    onFailure: (_) =>
        request == _request ? const <MentionPersonEntity>[] : null,
  );

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
