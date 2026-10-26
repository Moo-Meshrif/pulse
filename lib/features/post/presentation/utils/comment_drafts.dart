import 'package:injectable/injectable.dart';

/// The unsent comment text of each post, per account, kept until the app closes (not on disk).
@lazySingleton
class CommentDrafts {
  final _drafts = <String, String>{};

  String read(String userId, String postId) => _drafts['$userId/$postId'] ?? '';

  /// An empty [text] removes the draft.
  void save(String userId, String postId, String text) {
    if (text.trim().isEmpty) {
      _drafts.remove('$userId/$postId');
    } else {
      _drafts['$userId/$postId'] = text;
    }
  }
}
