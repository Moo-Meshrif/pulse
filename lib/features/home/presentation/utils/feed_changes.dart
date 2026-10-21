import 'feed_post.dart';

/// What a change check did to the feed's lists.
typedef FeedChangeResult = ({
  List<FeedPost> posts,
  List<FeedPost> pending,
  Set<String> replacedIds,
  Set<String> freshIds,
});

/// The feed's posts after a change check: a post in [replaced] is swapped for its new version where it
/// stands, a post whose id is in [gone] leaves, every other post stays.
List<FeedPost> applyFeedChanges(
  List<FeedPost> posts, {
  Map<String, FeedPost> replaced = const {},
  Set<String> gone = const {},
}) => [
  for (final post in posts)
    if (!gone.contains(post.id)) replaced[post.id] ?? post,
];

/// Puts what a change check read into the feed. [asked] are the ids that were read, [fresh] what came
/// back (a post the person can no longer see is missing).
///
/// - A post on the feed, or waiting in [pending], is replaced where it stands; a missing one leaves.
/// - A new post of the person's own goes to the top at once.
/// - Another person's new post waits in [pending], so what is being read does not move. A post that is
///   not newer than the newest one the feed holds belongs deeper down, where paging brings it.
FeedChangeResult applyFreshPosts({
  required List<FeedPost> posts,
  required List<FeedPost> pending,
  required List<FeedPost> fresh,
  required List<String> asked,
  required String? userId,
}) {
  final onFeed = {for (final post in posts) post.id};
  final waiting = {for (final post in pending) post.id};
  final byId = {for (final post in fresh) post.id: post};
  final missing = asked.where((id) => !byId.containsKey(id)).toSet();
  final replaced = {
    for (final entry in byId.entries)
      if (onFeed.contains(entry.key) || waiting.contains(entry.key))
        entry.key: entry.value,
  };

  final held = [...posts, ...pending];
  final newest = held.isEmpty
      ? null
      : held
            .map((post) => post.entity.createdAt)
            .reduce((a, b) => a.isAfter(b) ? a : b);
  final arrived = [
    for (final post in fresh)
      if (!replaced.containsKey(post.id) &&
          (newest == null || post.entity.createdAt.isAfter(newest)))
        post,
  ]..sort((a, b) => b.entity.createdAt.compareTo(a.entity.createdAt));
  final mine = [
    for (final post in arrived)
      if (post.entity.authorId == userId) post,
  ];
  final others = [
    for (final post in arrived)
      if (post.entity.authorId != userId) post,
  ];

  return (
    posts: [
      ...mine,
      ...applyFeedChanges(posts, replaced: replaced, gone: missing),
    ],
    pending: [
      ...others,
      ...applyFeedChanges(pending, replaced: replaced, gone: missing),
    ],
    replacedIds: replaced.keys.toSet(),
    freshIds: {for (final post in mine) post.id},
  );
}

/// The feed with the waiting posts on top, each once.
List<FeedPost> withPendingOnTop(List<FeedPost> posts, List<FeedPost> pending) {
  final waiting = {for (final post in pending) post.id};
  return [...pending, ...posts.where((post) => !waiting.contains(post.id))];
}
