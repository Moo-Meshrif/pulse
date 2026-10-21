import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/guard.dart';
import '../../../../core/utils/json_mapper.dart';
import '../enums/content_kind.dart';
import '../enums/pending_content_state.dart';
import '../model/content_cleanup_model.dart';
import '../model/pending_content_status_model.dart';

/// Posts, shorts and stories the server knows about before they are posted (drafts and shared items).
/// Every call is safe to repeat and throws a `Failure` on error. The calls that return a state return
/// null for a state this app does not know.
abstract interface class PendingContentDatasource {
  /// Opens the draft [id] of [kind] (a post or a short), or touches it when it is open already. Returns
  /// its state; anything but a draft must not be edited any more.
  Future<PendingContentState?> openDraft(String id, ContentKind kind);

  /// Saves what to post as [id], so the server can post it once its files are there. The same [request]
  /// again returns the current state (published when it already went out); a different one is refused.
  /// [request] is the `share_content` request JSON.
  Future<PendingContentState?> share(
    String id,
    ContentKind kind,
    Map<String, dynamic> request,
  );

  /// Posts the shared [id] now if all its files are there; waiting means some are not (or an older
  /// shared post goes first).
  Future<PendingContentState?> publish(String id);

  /// Marks [id] discarded, so it can never be posted; published means it already went out.
  Future<PendingContentState?> discard(String id, ContentKind kind);

  /// Where each of [ids] is; an id the server does not know is left out. Null [ids] asks for every item
  /// that is not finished (a draft, shared, rejected, or with files left to clean).
  Future<List<PendingContentStatusModel>> status(List<String>? ids);

  /// The signed-in user's discarded and abandoned items whose files should be deleted now, with those
  /// files. Never lists a file of a post or story, or anyone else's.
  Future<List<ContentCleanupModel>> cleanupList();

  /// Tells the server the files of [id] were deleted; returns how many are still there. With none left,
  /// the server lists the item once more a day later, for an upload that finished late.
  Future<int> confirmCleanup(String id);
}

/// [PendingContentDatasource] as an adapter over Supabase: `open_draft`, `share_content`,
/// `publish_content`, `discard_content`, `content_status`, `content_cleanup_list` and
/// `confirm_content_cleanup`.
@LazySingleton(as: PendingContentDatasource)
final class SupabasePendingContentDatasource
    implements PendingContentDatasource {
  SupabasePendingContentDatasource(this._client);

  /// Sharing, posting and discarding give up waiting after this; each is safe to send again.
  static const _answerTimeout = Duration(seconds: 20);

  final SupabaseClient _client;

  @override
  Future<PendingContentState?> openDraft(String id, ContentKind kind) =>
      _state('open_draft', {'p_id': id, 'p_kind': kind.wire});

  @override
  Future<PendingContentState?> share(
    String id,
    ContentKind kind,
    Map<String, dynamic> request,
  ) => _state('share_content', {
    'p_id': id,
    'p_kind': kind.wire,
    'p_request': request,
  }, timeout: _answerTimeout);

  @override
  Future<PendingContentState?> publish(String id) =>
      _state('publish_content', {'p_id': id}, timeout: _answerTimeout);

  @override
  Future<PendingContentState?> discard(String id, ContentKind kind) => _state(
    'discard_content',
    {'p_id': id, 'p_kind': kind.wire},
    timeout: _answerTimeout,
  );

  @override
  Future<List<PendingContentStatusModel>> status(List<String>? ids) =>
      Guard.run(() async {
        final rows = await _client.rpc<List<dynamic>>(
          'content_status',
          params: {'p_ids': ids},
        );
        return List<Map<String, dynamic>>.from(rows)
            .map(PendingContentStatusModel.fromJson)
            .toList();
      });

  @override
  Future<List<ContentCleanupModel>> cleanupList() => Guard.run(() async {
    final rows = await _client.rpc<List<dynamic>>('content_cleanup_list');
    return List<Map<String, dynamic>>.from(rows)
        .map(ContentCleanupModel.fromJson)
        .toList();
  });

  @override
  Future<int> confirmCleanup(String id) => Guard.run(() async {
    final left = await _client.rpc<dynamic>(
      'confirm_content_cleanup',
      params: {'p_id': id},
    );
    return JsonMapper.integer(left) ?? 0;
  });

  Future<PendingContentState?> _state(
    String function,
    Map<String, dynamic> params, {
    Duration? timeout,
  }) => Guard.run(() async {
    final call = _client.rpc<dynamic>(function, params: params);
    final state = await (timeout == null ? call : call.timeout(timeout));
    return PendingContentState.fromWire(state);
  });
}
