import '../../../post/presentation/utils/feed_post.dart';

/// What a change check did to the feed's lists.
typedef FeedChangeResult = ({
  List<FeedPost> posts,
  List<FeedPost> pending,
  Set<String> replacedIds,
});

/// The feed's posts after a change check: a post in [replaced] is swapped for its new version where it
/// stands, a post whose id is in [gone] leaves, every other post stays.
List<FeedPost> applyFeedChanges(
  List<FeedPost> posts, {
  Map<String, FeedPost> replaced = const {},
  Set<String> gone = const {},
}) => posts
    .where((post) => !gone.contains(post.id))
    .map((post) => replaced[post.id] ?? post)
    .toList();

/// Puts what a change check read into the feed. [asked] are the ids that were read, [fresh] what came
/// back (a post the person can no longer see is missing).
///
/// - A post on the feed, or waiting in [pending], is replaced where it stands; a missing one leaves.
/// - A new post, the person's own or another's, waits in [pending], so what is being read does not move
///   (the feed lets it in at once at the top, or when the person taps the pill). A post that is not
///   newer than the newest one the feed holds belongs deeper down, where paging brings it.
FeedChangeResult applyFreshPosts({
  required List<FeedPost> posts,
  required List<FeedPost> pending,
  required List<FeedPost> fresh,
  required List<String> asked,
}) {
  final onFeed = posts.map((post) => post.id).toSet();
  final waiting = pending.map((post) => post.id).toSet();
  final byId = Map.fromEntries(fresh.map((post) => MapEntry(post.id, post)));
  final missing = asked.where((id) => !byId.containsKey(id)).toSet();
  final replaced = Map.fromEntries(
    byId.entries.where(
      (entry) => onFeed.contains(entry.key) || waiting.contains(entry.key),
    ),
  );

  final held = [...posts, ...pending];
  final newest = held.isEmpty
      ? null
      : held
            .map((post) => post.entity.createdAt)
            .reduce((a, b) => a.isAfter(b) ? a : b);
  final arrived =
      fresh
          .where(
            (post) =>
                !replaced.containsKey(post.id) &&
                (newest == null || post.entity.createdAt.isAfter(newest)),
          )
          .toList()
        ..sort((a, b) => b.entity.createdAt.compareTo(a.entity.createdAt));

  return (
    posts: applyFeedChanges(posts, replaced: replaced, gone: missing),
    pending: [
      ...arrived,
      ...applyFeedChanges(pending, replaced: replaced, gone: missing),
    ],
    replacedIds: replaced.keys.toSet(),
  );
}

/// The feed with the waiting posts on top, each once.
List<FeedPost> withPendingOnTop(List<FeedPost> posts, List<FeedPost> pending) {
  final waiting = pending.map((post) => post.id).toSet();
  return [...pending, ...posts.where((post) => !waiting.contains(post.id))];
}
